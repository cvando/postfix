
useradd -s /bin/bash $1
echo "$1:$2" | chpasswd
chown -R $1:mail /var/spool/mail/$1
chmod -R a=rwx /var/spool/mail/$1
chmod -R o=- /var/spool/mail/$1


cd /etc/postfix/ssl/
openssl genrsa -des3 -rand /etc/hosts -out smtpd.key 1024
openssl req -new -key smtpd.key -out smtpd.csr
openssl x509 -req -days 3650 -in smtpd.csr -signkey smtpd.key -out smtpd.crt
openssl rsa -in smtpd.key -out smtpd.key.unencrypted
mv -f smtpd.key.unencrypted smtpd.key
chmod 600 smtpd.key
openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650 
cd /


service saslauthd start
service postfix start