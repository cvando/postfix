# Simple Postfix with sasl



### Docker run:

~~~ shell
$ docker run --restart=always -d -v /yourdir/main.cf:/main.cf -v /yourdir:/etc/postfix/ssl -v /yourdir/sasldb2:/etc/sasldb2 -p 587:587 -p 25:25 --name=postfix cvando/postfix
~~~

- Postfix config file --> /yourdir/main.cf

- Certificate/key      --> /youdir/ssl     smtpd.crt smtpd.key auto-generated, can be replace by letsencrypt cert.

- Users db                 --> /yourdir/sasldb2

  

### Add user:

```bash
$ docker exec -it postfix saslpasswd2 -c -u domain.com username
```



### List users:

```bash
$ docker exec -it postfix sasldblistusers2
```



### Test authentication:

*encode username@domain to base64*

*encode password to base64*

```shell
$ telnet localhost 25
EHLO test
AUTH LOGIN
username@domain.com64
password64
```

