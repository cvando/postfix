FROM ubuntu:16.04
MAINTAINER clement vandoolaeghe

# pre config
RUN echo mail > /etc/hostname; \
    echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt; \
    echo "postfix postfix/mailname string mail.example.com" >> preseed.txt

# load pre config for apt
RUN debconf-set-selections preseed.txt

# install
RUN apt-get update; apt-get install -y \
        libdb5.1 \
	postfix \
        syslog-ng \
        sasl2-bin \
	libsasl2-modules \
	libsasl2-modules-sql \
	libgsasl7 \
	libauthen-sasl-cyrus-perl \
	sasl2-bin libpam-mysql
RUN apt-get install --only-upgrade \
        glibc \
	util-linux \
	dpkg \
	shadow
	
	
# add user postfix to sasl group
RUN adduser postfix sasl


RUN    touch /etc/postfix/sasl/smtpd.conf 
RUN    echo 'pwcheck_method: saslauthd' >> /etc/postfix/sasl/smtpd.conf 
RUN    echo 'mech_list: plain login' >> /etc/postfix/sasl/smtpd.conf  
RUN    mkdir /etc/postfix/ssl 
RUN   sed -i "s/#submission/submission/g" /etc/postfix/master.cf 

# Configure SASL2

RUN   mkdir -p /var/spool/postfix/var/run/saslauthd 
RUN   rm -fr /var/run/saslauthd 
RUN   ln -s /var/spool/postfix/var/run/saslauthd /var/run/saslauthd 
RUN   chown -R root:sasl /var/spool/postfix/var/ 
RUN   chmod 710 /var/spool/postfix/var/run/saslauthd 
RUN   sed -i "s/START=no/START=yes/g" /etc/default/saslauthd 
RUN   sed -i 's/OPTIONS=.*/OPTIONS="-m \/var\/spool\/postfix\/var\/run\/saslauthd"/g' /etc/default/saslauthd


ADD   conf/main.cf /etc/postfix/main.cf
ADD   conf/syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

	
# Postfix Ports
EXPOSE 25
EXPOSE 587

# Add startup script
ADD startup.sh /startup.sh
RUN chmod a+x /startup.sh

# Docker startup
ENTRYPOINT ["/startup.sh"]
CMD ["-h"]
