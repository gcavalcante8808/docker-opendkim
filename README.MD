OpenDKIM Docker Image
---------------------

This is a gcavalcante8808/opendkim docker image based on official debian:latest image.

Simple Usage
------------

The fastest way to test this image is to use git and docker-compose to run all necessary pieces:

```
    cd /tmp
    git clone https://github.com/gcavalcante8808/docker-opendkim.git
    cd docker-opendkim
    docker-compose up -d
```

It will setUp an opendkim for the domain "example.com".

**The openkdim configuration needed to set into your dns be created automatically; check the logs and verify the value.**

Usage
-----

You need to provide the following Environment Variables:
 * POSTFIX_DOMAIN: the name of the domain, something like "yourdomain.com";
 * MAIL_DOMAIN: the name of the mx register of the domain, something like "mail.yourdomain.com";
 * DKIM_SHORTDOMAIN: the shortname of the domain, somethinglike "yourdomain".

And define --hostname parameter to the same value of "MAIL_DOMAIN".

With this information in hand, create the new container:

```
    docker run --name opendkim -d --hostname=mail.yourdomain.com -e POSTFIX_DOMAIN=yourdomain.com -e MAIL_DOMAIN=mail.yourdomain.com -e DKIM_SHORTDOMAIN=yourdomain gcavalcante8808/opendkim
```

After this, the opendkim will run in the port 5500/tcp. You need to check the logs to get the DNS configuration needed for the domain:

```
    docker logs opendkim
```

Thats it. If you already have an key for your domain, you can create a new container based on this one and copy your "domain.private" file to /etc/opendkim.


Author
------

Author: Gabriel Abdalla Cavalcante Silva (gabriel.cavalcante88@gmail.com)

