# run cmd
~~~ shell
$ docker run --restart=always -v /yourdir/main.cf:/etc/postfix/main.cf -v /yourdir:/etc/postfix/ssl -p 587:587 -p 25:25 --name=postfix cvando/postfix user pass domain
~~~
