#! /bin/bash

cp /etc/grid-security/tls.crt /etc/pki/tls/certs/localhost.crt
cp /etc/grid-security/tls.key /etc/pki/tls/private/localhost.key

echo "Starting jobber"
/usr/local/libexec/jobbermaster &

echo "Starting sendmail"
sendmail -bd

echo "Starting apache"
httpd -D FOREGROUND
