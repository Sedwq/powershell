# powershell
script powershell
Pour créer le USER ADMDBA, se connecter en root :

CREATE USER 'admdba'@'host' IDENTIFIED BY 'password';
GRANT SELECT ON *.* TO 'admdba'@'host' IDENTIFIED BY "password"; 
flush privileges;


Et surtout la partie ou on saute le filtrage à locahost uniquement (pour les version < 5.7) :

editer  /etc/my.cnf|ini

Puis :

mettre en commentaire : 
bind-address = 127.0.0.1

Si modification du fichier de config, restart mysql nécessaire.
