#!/bin/bash

#### Creating certificate ###################
if [ -e "/etc/postfix/ssl/smtpd.crt" ]; then
  echo "[run.sh] Using existing Certificat"
else
  echo "[run.sh] Creating new autosigned certificat"
  cd /etc/postfix/ssl/
  openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
  openssl rsa -passin pass:x -in server.pass.key -out smtpd.key
  rm server.pass.key
  openssl req -new -key smtpd.key -out server.csr \
    -subj "/C=FR/ST=IDF/L=PARIS/O=ORG/OU=OU/CN=POSTFIX"
  openssl x509 -req -days 3650 -in server.csr -signkey smtpd.key -out smtpd.crt
  cd /
fi

#### Configuring postfix ###################
if [ -e "/main.cf" ]; then
  echo "[run.sh] Copying user configuration file"
  cp /main.cf /etc/postfix/main.cf
else
  echo "[run.sh] Using default configuration file"
fi



#### fixing touch db #######################
if [ -e "/etc/sasldb2" ]; then
  echo "[run.sh] Using existing Database"
else
  touch /etc/sasldb2
  chown postfix /etc/sasldb2
  echo "[run.sh] V Initializing database not an error V"
  saslpasswd2 -p test@test.com
  saslpasswd2 -d test@test.com
  echo "[run.sh] ^ Initializing database don't worry ^"
fi

if [ -e "/etc/postfix/sasl_passwd" ]; then
  postmap hash:/etc/postfix/sasl_passwd
fi

if [ -e "/etc/postfix/sender_relay" ]; then
  postmap hash:/etc/postfix/sender_relay
fi

#### Starting rsyslog postfix ##############
exec supervisord -c /etc/supervisord.conf
