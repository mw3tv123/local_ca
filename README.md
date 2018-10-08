## Description:
- This is repo for Automated create SSL Certificate by generate Root CA, Intermediate CA and Server CA, add it to web server (nginx/apache).
- Client need to add Root Certificate to browser in order to sign the Server Certificate.

## How it work:
- (1) Generates Root Key (Root Private Key);
- (2) Using Root Key to generate Root Certificate (Root Public Key);
- (3) Generates Intermediate Key (Intermediate Private Key);
- (4) Using Intermediate Key to generate a Certificate Signing Request file (.csr file);
- (5) Using Root Certificate to sign CSR file to create Intermediate Certificate (Intermediate Public Key);
- (6) Generate Server Key (Server Private Key);
- (7) Using Server Key to generate a Server CSR file;
- (8) Using Intermediate Certificate to sign Server CSR file;
