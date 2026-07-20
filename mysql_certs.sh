#!/usr/bin/bash

## Create the Certificate Authority (CA): 
# Generate CA Private Key
openssl genrsa 2048 > ca-key.pem

# Generate CA Certificate
openssl req -new -x509 -nodes -days 3650 -key ca-key.pem -out ca.pem -subj '/C=US/ST=state/L=city/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com'


### Create the Server Certificate:
# Generate Server Private Key
openssl req -newkey rsa:2048 -nodes -days 3650 -keyout server-key.pem -out server-req.pem -subj '/C=US/ST=state/L=city/O=Organization/OU=Department/CN=server.example.com/emailAddress=you@example.com'

# Sign the Server Certificate with the CA
openssl x509 -req -days 3650 -in server-req.pem -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem


### Create the Client Certificate:
# Generate Client Private Key
openssl req -newkey rsa:2048 -days 3650 -nodes -keyout client-key.pem -out client-req.pem -subj '/C=US/ST=State/L=City/O=Organization/OU=Department/CN=client.example.com/emailAddress=you@example.com'

# Sign the Client Certificate with the CA
openssl x509 -req -days 3650 -in client-req.pem -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem
