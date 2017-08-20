#!/bin/bash
useradd -s /bin/bash $1
echo "$1:$2" | chpasswd
mkdir /var/spool/mail/$1
chown -R $1:mail /var/spool/mail/$1
chmod -R a=rwx /var/spool/mail/$1
chmod -R o=- /var/spool/mail/$1
touch /var/log/mail.log

sed -i "s/myhostname = server1.example.com/myhostname = $3/g" /etc/postfix/main.cf

service saslauthd start
service postfix start

tail -F /var/log/mail.log
