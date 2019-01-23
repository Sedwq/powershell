############################################################################################
#
#  Rapport mail MYSQL
#  CD V3.0 du 23/01/2019 Amélioration perf du script
#
############################################################################################
#Variables
$MonTableau = Get-Content C:\path\liste_bdd_prd.txt

#$MonTableau = Get-Content C:\exploit\liste_bdd_prd.txt
$objHashTableprd = @{} #Initialisation d'une hash table
$objHashTableprd2 = @{} #Initialisation d'une hash table
$objHashTablerct = @{} #Initialisation d'une hash table
$objHashTablerct2 = @{} #Initialisation d'une hash table
$Time = Get-Date
$fichtml="C:\path\fictosend.html"

$From = "XX@XX"
$To = "XX@XX"
$SMTPServer = "XXXX"
$subject = "Rapport des bases MySQL OK"

$user = "XXXXX"
$pwd = 'XXXXXXXXX'
$MYSQL = "C:\Program Files\MySQL\MySQL Server 5.0\bin\mysql.exe"
$query = "\s"

# Tests de connexion au serveur Mysql
############################################################################################
#prod
############################################################################################
foreach ($item in $MonTableau){

	$param = "-u$user","-h$item","-p$pwd","-s","-r","-N","-e$query"
    
    $result = & $MYSQL $param 2>&1
    
    if ($LastExitCode -ne 0)
    {
    $statu = "red"
	$subject = "Test - Rapport des bases MySQL KO"
	$item = $item + "<br>Connexion impossible au serveur mysql"
    }
    else
    {
    $statu = "green"
	$objHashTableprd2.Add("$item", "$result")
    }
    $objHashTableprd.Add("$item", "$statu")
}

# Initialisaton du fichier HTML    
$htm ="<title>Rapport Bases MYSQL</title>` 
		<HTML><HEAD></HEAD><BODY link=`"white`">` 
		<B><CENTER>Rapport de production du  $Time</CENTER></B><TABLE border=1>"

$htm | out-file $fichtml

$i=0    
$objHashTableprd.GetEnumerator() | ForEach-Object{
    $i=++$i
    $htm = '<TD BGCOLOR={1}><a href="#{0}">{0}</a></TD>' -f $_.key, $_.value
    $htm | out-file $fichtml -append
	if($i % 5 -eq 0){
	$htm = '</TR>'
	$htm | out-file $fichtml -append
	}
	
}
	
$htm1 = '</TABLE></BR></BR></BR>'
$htm1 | out-file $fichtml -append
    
# Construction corps fichier HTML production

$htm = '</BR><TABLE border=1 cellspacing=0 cellpadding=10><TD bgcolor=#CCCCCC width=360><a id=production></a>mysql - <i>production</i></TD>
            <TD bgcolor=#CCCCCC width=180> Version MySQL </TD>
            <TD bgcolor=#CCCCCC width=100> Port r&eacute;seau </TD></TD>
            <TD bgcolor=#CCCCCC width=100> Uptime MySQL </TD>'

$htm | out-file $fichtml -append

foreach($key in $objHashTableprd2.keys)
{
	 $vers = $objHashTableprd2[$key].Replace('Protocol version','') | %{ $_.Split(':')[7]; }
	 $port = $objHashTableprd2[$key].Replace('Uptime','') | %{ $_.Split(':')[14]; }
	 $upti = $objHashTableprd2[$key].Replace('Threads','') | %{ $_.Split(':')[15]; }
	
    $htm = '<TR><TD>{0}</TD>
            <TD BGCOLOR=green>{2}</TD>
            <TD BGCOLOR=green>{3}</TD>
            <TD BGCOLOR=green>{4}</TD></TR> ' -f $key, $objHashTableprd2[$key], $vers, $port, $upti
                        
   $htm | out-file $fichtml -append
}

$htm2 = '</TABLE></BR></BR></BR>
			</BODY></HTML>'

$htm2 | out-file $fichtml -append

############################################################################################
#recette
############################################################################################
$MonTableau2 = Get-Content C:\path\liste_bdd_rec.txt

# Tests de connexion au serveur Mysql
foreach ($item in $MonTableau2){

	$param = "-u$user","-h$item","-p$pwd","-s","-r","-N","-e$query"
    
    $result = & $MYSQL $param 2>&1
    
    if ($LastExitCode -ne 0)
    {
    $statu = "red"
	$subject = "Test - Rapport des bases MySQL KO"
	$item = $item + "<br>Connexion impossible au serveur mysql"
    }
    else
    {
    $statu = "green"
	$objHashTablerct2.Add("$item", "$result")
    }
    $objHashTablerct.Add("$item", "$statu")
}

# Initialisaton du fichier HTML    
$htm ="<B><CENTER>Rapport de recette du  $Time</CENTER></B><TABLE border=1>"

$htm | out-file $fichtml -append

$j=0
$objHashTablerct.GetEnumerator() | ForEach-Object{
    $j=++$j
    $htm = '<TD BGCOLOR={1}><a href="#{0}">{0}</a></TD>' -f $_.key, $_.value
    $htm | out-file $fichtml -append
	if($j % 5 -eq 0){
	$htm = '</TR>'
	$htm | out-file $fichtml -append
	}
}
	
$htm1 | out-file $fichtml -append

# Construction du corps fichier HTML recette

$htm = '</BR><TABLE border=1 cellspacing=0 cellpadding=10><TD bgcolor=#CCCCCC width=360><a id=recette></a>mysql - <i>recette</i></TD>
            <TD bgcolor=#CCCCCC width=180> Version MySQL </TD>
            <TD bgcolor=#CCCCCC width=100> Port r&eacute;seau </TD></TD>
            <TD bgcolor=#CCCCCC width=100> Uptime MySQL </TD>'

$htm | out-file $fichtml -append

foreach($key in $objHashTablerct2.keys)
{
	 $vers = $objHashTablerct2[$key].Replace('Protocol version','') | %{ $_.Split(':')[7]; }
	 $port = $objHashTablerct2[$key].Replace('Uptime','') | %{ $_.Split(':')[14]; }
	 $upti = $objHashTablerct2[$key].Replace('Threads','') | %{ $_.Split(':')[15]; }
	
    $htm = '<TR><TD>{0}</TD>
            <TD BGCOLOR=green>{2}</TD>
            <TD BGCOLOR=green>{3}</TD>
            <TD BGCOLOR=green>{4}</TD></TR> ' -f $key, $objHashTablerct2[$key], $vers, $port, $upti
                        
   $htm | out-file $fichtml -append
}

$htm2 | out-file $fichtml -append

#Envoi du mail avec pièce jointe
$body = Get-Content -Path $fichtml | Out-String

#Send-MailMessage -To $To -From $From -Cc $Cc -Subject $subject  -SmtpServer $SMTPServer -Body $body -BodyAsHtml
Send-MailMessage -To $To -From $From -Subject $subject  -SmtpServer $SMTPServer -Body $body -BodyAsHtml
