#!/usr/bin/env bash

#### Author: HUNG TRAN
#### Date: 10/10/2018
#### Descriptions: This script uses to create Server Certificate.

# Install 'expect' command
which expect | grep 'expect' &> /dev/null
if [ $? -ne 0 ]; then
  apt install -y expect
fi

cd $ROOT_CA_DIR

# Create the Intermediate key using expect
openssl genrsa -out intermediate/private/sv2.abc.key.pem 2048

# Change permission of the key for root only
chmod 400 intermediate/private/sv2.abc.key.pem

# Create the Server Certificate Signing Request - CSR file
expect << END
  spawn openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/sv2.abc.key.pem -out intermediate/csr/sv2.abc.csr.pem
  expect "Country Name*"
  sleep 2
  send "US\r"
  expect "*Province Name*"
  sleep 2
  send "California\r"
  expect "Locality Name*"
  sleep 2
  send "Mountain View\r"
  expect "Organization Name*"
  sleep 2
  send "$ORGANIZATION\r"
  expect "Organization Unit Name*"
  sleep 2
  send "Local Ltd Web Services\r"
  expect "Common Name*"
  sleep 2
  send "sv2.abc\r"
  expect "Email Address*"
  sleep 2
  send "\r"
  expect "#"
END

# Using Intermediate CA to sign for Server CSR file to create Server Certificate
expect << END
  spawn openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in intermediate/csr/sv2.abc.csr.pem -out intermediate/certs/sv2.abc.cert.pem
  expect "Sign the  certificate?*"
  sleep 2
  send "y\r"
  expect "*commit?*"
  sleep 2
  send "y\r"
  expect "#"
END

# Change permission of the root certificate to Read only
chmod 444 intermediate/certs/sv2.abc.cert.pem

# Verify the root certificate
openssl x509 -noout -text -in intermediate/certs/sv2.abc.cert.pem

# Create the certificate chain file
cat intermediate/certs/sv2.abc.cert.pem intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem

# Inform user after completed the process
echo "==> Progress generate Server CA was completed!"
echo "- Server CA directory: $ROOT_CA_DIR/intermediate"
echo "- Private key: $ROOT_CA_DIR/intermediate/private"
echo "- Certificate: $ROOT_CA_DIR/intermediate/certs"
