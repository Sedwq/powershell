#Version du 12 juillet 2018

Clear-Host
#$MonTableau = @('bdd1','bdd2','bdd3')
$MonTableau = Get-Content liste_bdd.txt


#Méthode 1
foreach ($item in $MonTableau){
	 $pwd = 'xxxxxxxxx'
	 $command = "system/$pwd@$($item)"
	 #Write-Host "sqlplus  -L $command 'C:\Master\@reque.sql'"
	 sqlplus -s -L $command "@reque.sql" | Select -Index 3,11 | out-file -Append 'c:\master\sql-output.txt'
}

# reste à gérer les erreurs de connexion, le formatage du fichier de sortie etc
