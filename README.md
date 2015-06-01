# client-cert-demo
A trivial dummy CA and client certificate authentication proxy demo


## Generate some dummy keys and certs

Generate a dummy CA, client key+cert and server key+cert from scratch: clone this repo and run `./go.sh`


## Set up your browser for certificate based authentication

Import the dummy client certificate `client/dummy-client.p12` to your browser. The password is `secret`. Don't tell anyone.

Eg. in Chrome: Settings > Advanced > HTTPS/SSL > Manage certificates > Import.


## Set up an nginx reverse proxy to handle client certificate authentication

Create an nginx configuration package, nginx.tar: `./go.sh package`

Copy the package to your server, install prerequisites, and deploy the config:
```
sudo apt-get update && sudo apt-get -y install openssl nginx
sudo tar oxvf nginx.tar -C /etc
sudo chmod 0600 /etc/nginx/ssl/dummy-server.key
sudo ln -s /etc/nginx/sites-available/nginx-client-auth.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo service nginx restart
```

The provided configuration sets up a reverse proxy to http://scooterlabs.com/echo


## Try it

Fetch https://your.host/echo and inspect the result. If there was much success, the result should contain something like this:
```
    [headers] => Array
        (
            [X-Client-Cert-Verify] => SUCCESS
            [X-Client-Cert-Subject-DN] => /C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=Dummy Client
            [X-Client-Cert-Issuer-DN] => /C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=Dummy CA
```


# TODO
CRL

# Acknowledgements
This stuff is inspired by and mostly based on [an article by Nate Good](http://nategood.com/client-side-certificate-authentication-in-ngi).

We're using Brian Cantoni's [Echo Service](http://www.cantoni.org/2012/01/08/simple-webservice-echo-test) to check our headers.

Much appreciated. Thanks!

# Further reading
* On running your own Certificate Authority: https://jamielinux.com/blog/category/CA/