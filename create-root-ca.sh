#!/usr/bin/env bash

#### Author: HUNG TRAN
#### Date: 09/10/2018
#### Descriptions: This script uses to create Root CA.

# Install 'expect' command
which expect | grep 'expect' &> /dev/null
if [ $? -ne 0 ]; then
  apt-get install -y expect
fi

# Check if Root directory exists or not
if [ -e $ROOT_CA_DIR ]; then
  rm -r $ROOT_CA_DIR
fi

mkdir -p $ROOT_CA_DIR && cd $ROOT_CA_DIR

# Prepare the Root directory
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Copy and modify OpenSSL's configuration file
cp ~/local_ca/root-config.txt $ROOT_CA_DIR/openssl.cnf

# Create the Root key using expect
expect << END
  spawn openssl genrsa -aes256 -out private/ca.key.pem 4096
  expect "*ca.key.pem:"
  send "$ROOT_CA_PASSWORD\r"
  expect "Verifying*"
  send "$ROOT_CA_PASSWORD\r"
  expect "#"
END

# Change permission of the key for root only
chmod 400 private/ca.key.pem

# Create the Root Certificate
expect << END
  spawn openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
  expect "*ca.key.pem:*"
  send "$ROOT_CA_PASSWORD\r"
  expect "*[GB]:"
  send "$COUNTRY\r"
  expect "*Province*"
  send "$PROVINCE\r"
  expect "Locality*"
  send "\r"
  expect "Organization Name*"
  send "$ORGANIZATION\r"
  expect "Organization Unit Name*"
  send "$ORGANIZATION_UNIT\r"
  expect "Common Name*"
  send "$COMMON_NAME\r"
  expect "#"
END

# Change permission of the root certificate to Read only
chmod 444 certs/ca.cert.pem

# Verify the root certificate
openssl x509 -noout -text -in certs/ca.cert.pem
