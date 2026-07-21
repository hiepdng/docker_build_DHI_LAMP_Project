#!/usr/bin/bash

### Check if openssl exists
which openssl || { echo 'openssl not found' ; echo Exit...; }

### Create certs/httpd directory
if [ ! -d "certs/httpd" ]; then
    echo "Create certs/httpd directory."
    mkdir -p certs/httpd
fi

### Create certs/mysql directory
if [ ! -d "certs/mysql" ]; then
    echo "Create certs/mysql directory."
    mkdir -p certs/mysql
fi


### For HTTPD
# Create a self-signed SSL Certificate for testing purposes:
openssl genrsa -des3 -passout pass:YourPasswordHere -out certs/httpd/server.key.secure
openssl rsa -in certs/httpd/server.key.secure -passin pass:YourPasswordHere -out certs/httpd/server.key # decrypted server.key, used for auto start web withour password
openssl req -new -x509 -nodes -sha1 -days 365 -key certs/httpd/server.key -out certs/httpd/server.crt -extensions usr_cert  -subj "/C=US/ST=state/L=City/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com"


### For MySQL
## Create the Certificate Authority (CA): 
# Generate CA Private Key
openssl genrsa 2048 > mysql_certs/ca-key.pem

# Generate CA Certificate
openssl req -new -x509 -nodes -days 3650 -key certs/mysql/ca-key.pem -out certs/mysql/ca.pem -subj '/C=US/ST=state/L=city/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com'


### Create the Server Certificate:
# Generate Server Private Key
openssl req -newkey rsa:2048 -nodes -days 3650 -keyout certs/mysql/server-key.pem -out certs/mysql/server-req.pem -subj '/C=US/ST=state/L=city/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com'

# Sign the Server Certificate with the CA
openssl x509 -req -days 3650 -in certs/mysql/server-req.pem -CA certs/mysql/ca.pem -CAkey certs/mysql/ca-key.pem -set_serial 01 -out certs/mysql/server-cert.pem


### Create the Client Certificate:
# Generate Client Private Key
openssl req -newkey rsa:2048 -days 3650 -nodes -keyout certs/mysql/client-key.pem -out certs/mysql/client-req.pem -subj '/C=US/ST=State/L=City/O=Organization/OU=Department/CN=client.example.com/emailAddress=you@example.com'

# Sign the Client Certificate with the CA
openssl x509 -req -days 3650 -in certs/mysql/client-req.pem -CA certs/mysql/ca.pem -CAkey certs/mysql/ca-key.pem -set_serial 01 -out certs/mysql/client-cert.pem
