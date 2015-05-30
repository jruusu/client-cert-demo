# client-cert-demo
A trivial dummy CA and client certificate demo

Generate a dummy CA, client key and certificate from scratch, clone this repo and run `./go.sh`

Import the dummy client certificate (client/dummy-client.p12) to your browser. Eg. Chrome: Settings > Advanced > HTTPS/SSL >Manage certificates > Import.

Create an nginx configuration package, nginx.tar: `./go.sh package`

Copy the package to your server, install prerequisites, and deploy the config:
```
sudo apt-get update && sudo apt-get -y install openssl nginx
sudo tar oxvf nginx.tar -C /etc
sudo chmod 0600 /etc/nginx/ssl/dummy-server.key
sudo ln -s /etc/nginx/sites-available/nginx-client-auth.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo service nginx restart
```

# TODO
Nginx reverse proxy
CRL

# Acknowledgements
This stuff is inspired by mostly based on [an article by Nate Good](http://nategood.com/client-side-certificate-authentication-in-ngi).

Thanks!
