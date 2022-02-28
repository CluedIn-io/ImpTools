set PFX_FILE=apac-cert-kv-wildcard-k1-cluedin-me-20220108.pfx

rem extract private key
"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -in %PFX_FILE% -nocerts -out key.pem -passin pass: -passout pass:xxxx

rem remove the password (paraphrase) from the private key
"C:\Program Files\Git\usr\bin\openssl.exe" rsa -in key.pem -out server.key -passin pass:xxxx

rem extract public key
"C:\Program Files\Git\usr\bin\openssl.exe" pkcs12 -in %PFX_FILE% -clcerts -nokeys -out cert.pem -passin pass:

