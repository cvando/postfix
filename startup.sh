#!/bin/bash
useradd -s /bin/bash $1
echo "$1:$2" | chpasswd
mkdir /var/spool/mail/$1
chown -R $1:mail /var/spool/mail/$1
chmod -R a=rwx /var/spool/mail/$1
chmod -R o=- /var/spool/mail/$1
touch /var/log/mail.log
sed -i "s/myhostname = server1.example.com/myhostname = $3/g" /etc/postfix/main.cf

if [ -e "/etc/postfix/ssl/smtpd.crt" ]; then
  echo "Certificat already created"

else
  echo "Creating certificat"
  cd /etc/postfix/ssl/
  openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
  openssl rsa -passin pass:x -in server.pass.key -out smtpd.key
  rm server.pass.key
  openssl req -new -key smtpd.key -out server.csr \
    -subj "/C=FR/ST=IDF/L=paris/O=org/OU=ou/CN=postfix"
  openssl x509 -req -days 3650 -in server.csr -signkey smtpd.key -out smtpd.crt
  cd /
fi


service syslog-ng start
service saslauthd start
service postfix start

tail -F /var/log/mail.*
