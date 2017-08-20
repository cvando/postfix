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
        rsyslog \
        sasl2-bin \
	libsasl2-modules \
	libsasl2-modules-sql \
	libgsasl7 \
	libauthen-sasl-cyrus-perl \
	sasl2-bin libpam-mysql
	
# add user postfix to sasl group
RUN adduser postfix sasl
	
# Configure postfix

RUN    postconf -e 'smtpd_sasl_local_domain =' 
RUN    postconf -e 'smtpd_sasl_auth_enable = yes' 
RUN    postconf -e 'smtpd_sasl_security_options = noanonymous' 
RUN    postconf -e 'broken_sasl_auth_clients = yes' 
RUN    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination' 
RUN    postconf -e 'inet_interfaces = all' 
RUN	   postconf -e 'smtpd_tls_auth_only = no' 
RUN    postconf -e 'smtp_use_tls = yes' 
RUN    postconf -e 'smtp_tls_note_starttls_offer = yes' 
RUN    postconf -e 'myhostname = server1.example.com' 
RUN    postconf -e 'always_add_missing_headers = yes'

RUN    touch /etc/postfix/sasl/smtpd.conf 
RUN    echo 'pwcheck_method: saslauthd' >> /etc/postfix/sasl/smtpd.conf 
RUN    echo 'mech_list: plain login' >> /etc/postfix/sasl/smtpd.conf  
RUN    mkdir /etc/postfix/ssl 


# Configure SASL2

RUN   mkdir -p /var/spool/postfix/var/run/saslauthd 
RUN   rm -fr /var/run/saslauthd 
RUN   ln -s /var/spool/postfix/var/run/saslauthd /var/run/saslauthd 
RUN   chown -R root:sasl /var/spool/postfix/var/ 
RUN   chmod 710 /var/spool/postfix/var/run/saslauthd 

RUN   sed -i "s/START=no/START=yes/g" /etc/default/saslauthd 
RUN   sed -i 's/OPTIONS=.*/OPTIONS="-m \/var\/spool\/postfix\/var\/run\/saslauthd"/g' /etc/default/saslauthd
	
	
	
# Postfix Ports
EXPOSE 25

# Add startup script
ADD startup.sh /startup.sh
RUN chmod a+x /startup.sh

# Docker startup
ENTRYPOINT ["/startup.sh"]
CMD ["-h"]
