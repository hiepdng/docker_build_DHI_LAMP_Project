#!/usr/bin/bash

### Load variables from .env file
set -o allexport
source .env
set +o allexport

### Check if openssl exists
which openssl || { echo 'openssl not found' ; echo Exit...; }


### For HTTPD -----------------------------------------------------------------
if [ ! -d "certs/httpd" ]; then
    echo "Create certs/httpd directory."
    mkdir -p certs/httpd
fi

# Create a self-signed SSL Certificate for testing purposes:
openssl genrsa -des3 -passout pass:YourPasswordHere -out certs/httpd/server.key.secure
openssl rsa -in certs/httpd/server.key.secure -passin pass:YourPasswordHere -out certs/httpd/server.key # decrypted server.key, used for auto start web withour password
openssl req -new -x509 -nodes -sha1 -days 365 -key certs/httpd/server.key -out certs/httpd/server.crt -extensions usr_cert  -subj ${HTTPD_CERT_SUBJ}

# Modify httpd.conf and httpd-ssl.conf
sed -i \
    -e "s/^#ServerName www.example.com:80/ServerName ${SERVER_NAME}/" \
    -e "s/^#\(Include .*httpd-ssl.conf\)/\1/" \
    -e "s/^#\(LoadModule .*mod_ssl.so\)/\1/" \
    -e "s/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/" \
    -e "s/^#\(LoadModule .*mod_proxy.so\)/\1/" \
    -e "s/^#\(LoadModule .*mod_proxy_fcgi.so\)/\1/" \
    -e "s/DirectoryIndex index.html/DirectoryIndex index.php index.html/" \
    ./etc/httpd.conf

# Modify httpd-ssl.conf file
sed -i \
    -e "s/^ServerName www.example.com:443/ServerName ${SERVER_NAME}:443/" \
    -e "s/^ServerAdmin you@example.com/ServerAdmin ${SERVER_ADMIN}/" \
    -e "s/^SSLCertificateFile.*/SSLCertificateFile \/usr\/local\/apache2\/conf\/certs\/server.crt/" \
    -e "s/^SSLCertificateKeyFile.*/SSLCertificateKeyFile \/usr\/local\/apache2\/conf\/certs\/server.key/" \
    ./etc/httpd-ssl.conf




### For MySQL -----------------------------------------------------------------
if [ ! -d "certs/mysql" ]; then
    echo "Create certs/mysql directory."
    mkdir -p certs/mysql
fi

## Create the Certificate Authority (CA): 
# Generate CA Private Key
openssl genrsa 2048 > certs/mysql/ca-key.pem

# Generate CA Certificate
openssl req -new -x509 -nodes -days 3650 -key certs/mysql/ca-key.pem -out certs/mysql/ca.pem -subj ${MYSQL_SERVER_CERT_SUBJ}


### Create the Server Certificate:
# Generate Server Private Key
openssl req -newkey rsa:2048 -nodes -days 3650 -keyout certs/mysql/server-key.pem -out certs/mysql/server-req.pem -subj ${MYSQL_SERVER_CERT_SUBJ}

# Sign the Server Certificate with the CA
openssl x509 -req -days 3650 -in certs/mysql/server-req.pem -CA certs/mysql/ca.pem -CAkey certs/mysql/ca-key.pem -set_serial 01 -out certs/mysql/server-cert.pem


### Create the Client Certificate:
# Generate Client Private Key
openssl req -newkey rsa:2048 -days 3650 -nodes -keyout certs/mysql/client-key.pem -out certs/mysql/client-req.pem -subj ${MYSQL_CLIENT_CERT_SUBJ}

# Sign the Client Certificate with the CA
openssl x509 -req -days 3650 -in certs/mysql/client-req.pem -CA certs/mysql/ca.pem -CAkey certs/mysql/ca-key.pem -set_serial 01 -out certs/mysql/client-cert.pem




### For PHP-FPM ---------------------------------------------------------------
sed -i \
        -e "s/^\(max_execution_time.*\)/;\1\nmax_execution_time = 60/" \
        -e "s/^\(max_input_time.*\)/;\1\nmax_input_time = 60/" \
        -e "s/^\(;max_input_vars.*\)/;\1\nmax_input_vars = 3000/" \
        -e "s/^\(memory_limit.*\)/;\1\nmemory_limit = 256M/" \
        -e "s/^\(post_max_size.*\)/;\1\npost_max_size = 64M/" \
        -e "s/^\(upload_max_filesize.*\)/;\1\nupload_max_filesize = 64M/" \
        -e "s/^\(display_errors.*\)/;\1\ndisplay_errors = Off/" \
        -e "s/^\(display_startup_errors.*\)/;\1\ndisplay_startup_errors = Off/" \
        -e "s/^\(log_errors.*\)/;\1\nlog_error = On/" \
        -e "s/^\(error_reporting.*\)/;\1\nerror_reporting = E_ALL \\& ~E_DEPRECATED \\& ~E_STRICT/" \
        -e "s/^\(expose_php.*\)/;\1\nexpose_php = Off/" \
        -e "s/^\(session.use_only_cookies.*\)/;\1\nsession.use_only_cookies = 1/" \
        -e "s/^\(session.cookie_httponly.*\)/;\1\nsession.cookie_httponly = 1/" \
        -e "s/^;\(session.cookie_secure.*\)/;\1\nsession.cookie_secure = 1/" \
        -e "s/^\(session.use_strict_mode.*\)/;\1\nsession.use_strict_mode = 1/" \
        -e "s/^\(session.cookie_samesite.*\)/;\1\nsession.cookie_samesite = "Lax"/" \
        -e "s/^\(allow_url_fopen.*\)/;\1\nallow_url_fopen = Off/" \
        -e "s/^\(allow_url_include.*\)/;\1\nallow_url_include = Off/" \
        -e "s/^\(disable_functions.*\)/;\1\ndisable_functions = exec,shell_exec,passthru,system,popen,proc_open/" \
        -e "s/^;\(opcache.enable=.*\)/;\1\nopcache.enable = 1/" \
        -e "s/^;\(opcache.enable_cli.*\)/;\1\nopcache.enable_cli = 1/" \
        -e "s/^;\(opcache.memory_consumption.*\)/;\1\nopcache.memory_consumption = 128/" \
        -e "s/^;\(opcache.interned_strings_buffer.*\)/;\1\nopcache.interned_strings_buffer = 8/" \
        -e "s/^;\(opcache.max_accelerated_files.*\)/;\1\nopcache.max_accelerated_files = 10000/" \
        -e "s/^;\(opcache.validate_timestamps.*\)/;\1\nopcache.validate_timestamps = 0/" \
    ./etc/php.ini


