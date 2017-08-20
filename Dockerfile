FROM ubuntu:16.04
MAINTAINER clement vandoolaeghe

# install
RUN apt-get update; apt-get install -y \
    libdb5.1 \
	postfix \
	procmail \
	sasl2-bin \
	libsasl2-modules \
	libsasl2-modules-sql \
	libgsasl7 \
	libauthen-sasl-cyrus-perl \
	sasl2-bin libpam-mysql
	
# add user postfix to sasl group
RUN adduser postfix sasl
	
# Configure postfix

RUN postconf -e 'smtpd_sasl_local_domain =' \
    postconf -e 'smtpd_sasl_auth_enable = yes' \
    postconf -e 'smtpd_sasl_security_options = noanonymous' \
    postconf -e 'broken_sasl_auth_clients = yes' \
    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination' \
    postconf -e 'inet_interfaces = all' \
    touch /etc/postfix/sasl/smtpd.conf \
    echo 'pwcheck_method: saslauthd' >> /etc/postfix/sasl/smtpd.conf \
    echo 'mech_list: plain login' >> /etc/postfix/sasl/smtpd.conf  \
    mkdir /etc/postfix/ssl \
	postconf -e 'smtpd_tls_auth_only = no' \
    postconf -e 'smtp_use_tls = yes' \
    postconf -e 'smtpd_use_tls = yes' \
    postconf -e 'smtp_tls_note_starttls_offer = yes' \
    postconf -e 'smtpd_tls_key_file = /etc/postfix/ssl/smtpd.key' \
    postconf -e 'smtpd_tls_cert_file = /etc/postfix/ssl/smtpd.crt' \
    postconf -e 'smtpd_tls_CAfile = /etc/postfix/ssl/cacert.pem' \
    postconf -e 'smtpd_tls_loglevel = 1' \
    postconf -e 'smtpd_tls_received_header = yes' \
    postconf -e 'smtpd_tls_session_cache_timeout = 3600s' \
    postconf -e 'tls_random_source = dev:/dev/urandom' \
    postconf -e 'myhostname = server1.example.com' \


# Configure SASL2

RUN mkdir -p /var/spool/postfix/var/run/saslauthd \
    rm -fr /var/run/saslauthd \
    ln -s /var/spool/postfix/var/run/saslauthd /var/run/saslauthd \
    chown -R root:sasl /var/spool/postfix/var/ \
    chmod 710 /var/spool/postfix/var/run/saslauthd \

# Postfix Ports
EXPOSE 25

# Add startup script
ADD startup.sh /opt/startup.sh
RUN chmod a+x /opt/startup.sh

# Docker startup
ENTRYPOINT ["/opt/startup.sh"]
CMD ["-h"]