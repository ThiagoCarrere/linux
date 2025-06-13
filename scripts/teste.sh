#criando pastas privadas
mkdir nome_pasta_privada

#criando grupos
groudadd nome_grupo

#criando usuario sem criar pasta e sem permissao de login
adduser --no-create-home --disabled-login nome_usuario

#vinculando pastas aos grupos
chgrp nome_grupo nome_pasta_privada

#inserindo usuario em grupo
usermod -aG nome_grupo nome_usuario

#verificando se o usuario tem acesso ao grupo
groups nome_usuario

#criando senha no samba para o usuario
smbpasswd -a nome_usuario

#criando permissao de acesso a pasta
chmod -R 770 nome_pasta_privada    






