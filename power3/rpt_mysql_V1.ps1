#########################################################
#
#  Rapport mail MYSQL
#  CD V1.0 du 08/01/2019
#
#########################################################

#Variables
$MonTableau = Get-Content C:\path\liste_bdd_rec.txt
#$MonTableau = Get-Content C:\exploit\liste_bdd_prd.txt
$objHashTable = @{} #Initialisation d'une hash table
$Time=Get-Date
$fichtml="C:\path\fictosend.html"

$From = "adm@dba"
$To = "ced.adm@dba.fr"
#$To = "test@test.fr"
$SMTPServer = "smtp"
$subject = "Rapport des bases MySQL OK"

$user = "admdba"
$pwd = "xxxxxxxxxxxxxx"
$MYSQL = "C:\Program Files\MySQL\MySQL Server 5.0\bin\mysql.exe"

$query1 = "SELECT SUBSTRING_INDEX(@@hostname, '.', +1) ;"
$query2 = "SELECT ROUND(sum( data_length + index_length) / 1024 / 1024 / 1024, 2) FROM information_schema.TABLES ;"
$query3 = "SHOW VARIABLES LIKE 'port' ;"
$query4 = "\s"
$query5 = "SHOW VARIABLES LIKE 'storage_engine' ;"

# Tests de connexion au serveur Mysql
foreach ($item in $MonTableau){

	$params1 = "-u$user","-h$item","-p$pwd","-s","-r","-N","-e$query1"
    
    $result1 = & $MYSQL $params1 2>&1
    
    if ($LastExitCode -ne 0)
    {
    $statu = "red"
	$subject = "Test - Rapport des bases MySQL KO"
	$item = $item + "<br>Connexion impossible au serveur mysql"
    }
    else
    {
    $statu = "green"
	
    }
    $objHashTable.Add("$item", "$statu")
}

# Initialisaton du fichier HTML    
$pied ="<title>Rapport Bases SQL Server</title>` 
		<HTML><HEAD></HEAD><BODY link=`"white`">` 
		<B><CENTER>Rapport du $Time</CENTER></B><TABLE border=1>"

$pied | out-file $fichtml
    
$objHashTable.GetEnumerator() | ForEach-Object{
    
    $mess = '<TD BGCOLOR={1}><a href="#{0}">{0}</a></TD>' -f $_.key, $_.value
    $mess | out-file $fichtml -append
}
	
$mess2 = '</TABLE></BR></BR></BR>'
$mess2 | out-file $fichtml -append
    
#Suppression du/des serveur(s) en echec de connexion
$ht2 = $objHashTable.Clone()
    
foreach($k in $objHashTable.GetEnumerator()){ 
    if($k.Value -eq "RED"){
        #notice, deleting from clone, then return clone at the end
        $ht2.Remove($k.Key) 
        }
}

# Construction corps fichier HTML rectte

$mess_rec = '</BR><TABLE border=1 cellspacing=0 cellpadding=10><TD bgcolor=#CCCCCC width=360><a id=recette></a>mysql - <i>recette</i></TD>
            <TD bgcolor=#CCCCCC width=180> Taille BDD en GB </TD>
            <TD bgcolor=#CCCCCC width=180> Port r&eacute;seau </TD>
            <TD bgcolor=#CCCCCC width=180> Version MySQL </TD>
            <TD bgcolor=#CCCCCC width=100> Uptime MySQL </TD></TD>
            <TD bgcolor=#CCCCCC width=100> Moteur de stockage </TD>'

$mess_rec | out-file $fichtml -append

foreach($key in $ht2.keys)
{
    $params2 = "-u$user","-h$key","-p$pwd","-s","-r","-N","-e$query2"
    $params3 = "-u$user","-h$key","-p$pwd","-s","-r","-N","-e$query3"
    $params4 = "-u$user","-h$key","-p$pwd","-s","-r","-N","-e$query4"
    $params5 = "-u$user","-h$key","-p$pwd","-s","-r","-N","-e$query5"

    
    $result2 = & $MYSQL $params2 2>&1
    $result3 = & $MYSQL $params3 2>&1
    $result4 = & $MYSQL $params4 | Select -Index 8 2>&1
    $result5 = & $MYSQL $params4 | Select -Index 16 2>&1
	$result6 = & $MYSQL $params5 2>&1
	
	$result4 = $result4.Replace('Server version:','')
	$result5 = $result5.Replace('Uptime:','')
	$result6 = $result6.Replace('storage_engine','')
	

    $message = '<TR><TD>{0}</TD>
            <TD BGCOLOR={1}>{2}</TD>
            <TD BGCOLOR={1}>{3}</TD>
            <TD BGCOLOR={1}>{4}</TD>
            <TD BGCOLOR={1}>{5}</TD>
            <TD BGCOLOR={1}>{6}</TD></TR> ' -f $key, $ht2[$key], $result2, $result3, $result4, $result5, $result6
                        
   $message | out-file $fichtml -append
}

$mess_rec2 = '</TABLE></BR></BR></BR>
			</BODY></HTML>'

$mess_rec2 | out-file $fichtml -append


# Construction corps fichier HTML rectte
$mess_prd1 ='<B><CENTER>PROD : Build on progress ... </CENTER></B>'

$mess_prd1 | out-file $fichtml -append

#Envoi du mail avec pièce jointe
$body = Get-Content -Path $fichtml | Out-String

Send-MailMessage -To $To -From $From -Subject $subject  -SmtpServer $SMTPServer -Body $body -BodyAsHtml
