#!/usr/bin/bash

### Check if openssl exists
which openssl || { echo 'openssl not found' ; echo Exit...; }

### Create mysql_certs directory
if [ ! -d "mysql_certs" ]; then
    echo "Create mysql_certs directory."
    mkdir mysql_certs && chown 65532:65532 mysql_certs
fi

## Create the Certificate Authority (CA): 
# Generate CA Private Key
openssl genrsa 2048 > mysql_certs/ca-key.pem

# Generate CA Certificate
openssl req -new -x509 -nodes -days 3650 -key mysql_certs/ca-key.pem -out mysql_certs/ca.pem -subj '/C=US/ST=state/L=city/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com'


### Create the Server Certificate:
# Generate Server Private Key
openssl req -newkey rsa:2048 -nodes -days 3650 -keyout mysql_certs/server-key.pem -out mysql_certs/server-req.pem -subj '/C=US/ST=state/L=city/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com'

# Sign the Server Certificate with the CA
openssl x509 -req -days 3650 -in mysql_certs/server-req.pem -CA mysql_certs/ca.pem -CAkey mysql_certs/ca-key.pem -set_serial 01 -out mysql_certs/server-cert.pem


### Create the Client Certificate:
# Generate Client Private Key
openssl req -newkey rsa:2048 -days 3650 -nodes -keyout mysql_certs/client-key.pem -out mysql_certs/client-req.pem -subj '/C=US/ST=State/L=City/O=Organization/OU=Department/CN=client.example.com/emailAddress=you@example.com'

# Sign the Client Certificate with the CA
openssl x509 -req -days 3650 -in mysql_certs/client-req.pem -CA mysql_certs/ca.pem -CAkey mysql_certs/ca-key.pem -set_serial 01 -out mysql_certs/client-cert.pem
