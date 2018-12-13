$From = "toto@toto.zh"
$To = "me@home.zh"
$SMTPServer = "smtp"
#$SMTPPort = "465"
$Username = "toto"
$subject = "test from me"
#$body = Get-Content -Path C:\Users\demar_c\Documents\powershell_script\bases_SQL.html -Raw for 
#higher version of powershell
$body = Get-Content -Path C:\Users\demar_c\Documents\powershell_script\bases_SQL.html | Out-String 
#$Attachments = "bases_SQL.html"

#$PWord = ConvertTo-SecureString –String "******" –AsPlainText -Force
#$Credential = New-Object System.Management.Automation.PSCredential ($Username, $PWord)

Send-MailMessage -To $To -From $From -Subject $subject  -SmtpServer $SMTPServer -Body $body -BodyAsHtml
