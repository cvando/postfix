FROM alpine
LABEL version="2.2"

RUN	apk add --no-cache --update postfix ca-certificates openssl libsasl cyrus-sasl supervisor rsyslog bash

RUN    mkdir /etc/postfix/ssl 
#RUN    sed -i "s/#submission/submission/g" /etc/postfix/master.cf 

COPY    conf/main.cf /etc/postfix/main.cf
COPY	conf/supervisord.conf /etc/supervisord.conf
COPY	conf/rsyslog.conf /etc/rsyslog.conf
COPY	run.sh /run.sh
RUN	    chmod +x /run.sh

USER	root

EXPOSE  587
EXPOSE  25

ENTRYPOINT ["/run.sh"]
