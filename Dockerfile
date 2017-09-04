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
RUN    postconf -e 'smtp_tls_note_starttls_offer = yes' 
RUN    postconf -e 'smtpd_tls_CAfile = /etc/postfix/ssl/cacert.pem'
RUN    postconf -e 'smtpd_tls_key_file = /etc/postfix/ssl/smtpd.key' 
RUN    postconf -e 'smtpd_tls_cert_file = /etc/postfix/ssl/smtpd.crt' 
RUN    postconf -e 'smtpd_tls_loglevel = 1' 
RUN    postconf -e 'smtpd_tls_received_header = yes' 
RUN    postconf -e 'smtpd_tls_session_cache_timeout = 3600s'
RUN    postconf -e 'tls_random_source = dev:/dev/urandom' 

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


# syslog-ng
# Replace the system() source because inside Docker we can't access /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
RUN	sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf
# Uncomment 'SYSLOGNG_OPTS="--no-caps"' to avoid the following warning:
# syslog-ng: Error setting capabilities, capability management disabled; error='Operation not permitted'
# http://serverfault.com/questions/524518/error-setting-capabilities-capability-management-disabled#
RUN	sed -i 's/^#\(SYSLOGNG_OPTS="--no-caps"\)/\1/g' /etc/default/syslog-ng
	
	
# Postfix Ports
EXPOSE 25
EXPOSE 587

# Add startup script
ADD startup.sh /startup.sh
RUN chmod a+x /startup.sh

# Docker startup
ENTRYPOINT ["/startup.sh"]
CMD ["-h"]
