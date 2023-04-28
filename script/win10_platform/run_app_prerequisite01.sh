# yarn dev (frontend)
$env:NODE_ENV="development"; $env:PORT=3000; $env:NODE_OPTIONS=--openssl-legacy-provider; yarn dev --https --cert fullchain.pem --key privkey.pem --config preact.config.js

# vite (frontend)
$env:NODE_ENV="development"; rimraf dev-dist; cross-env DEBUG=vite-plugin-pwa:* vite --force --port 3033

# uvicorn #in win10 cannot use gunicorn, just use uvicorn (FASTAPI)
uvicorn read_gebco01:app

# openssl see https://gist.github.com/cecilemuller/9492b848eb8fe46d462abeb26656c4f8
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=TW/CN=ODB-Root-CA"
openssl x509 -outform pem -in RootCA.pem -out RootCA.crt

```domains.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
```

openssl req -new -nodes -newkey rsa:2048 -keyout privkey.pem -out localhost.csr -subj "/C=TW/ST=Taiwan/L=Taipei/O=ODB-Certificates/CN=localhost.local"
openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile domains.ext -out fullchain.pem

# openssl Store CA to client browser when running HTTPS app
# chrome safety settings -> "Trusted Root Certification Authorities" -> import RootCA.crt

# fix: no need to modify $cd C:\Windows\System32\drivers\etc\hosts 
```hosts
#127.0.0.1       localhost
#::1             localhost
# Added by Docker Desktop
# To allow the same kube context to work on the host and the container: 127.0.0.1
# 127.0.0.1 kubernetes.docker.internal  # not sure -> 127.0.1.1?
```

# mongodb js for importing data
# in win10, must first download mongosh and login and run snippet install mongocompat, and then run (but only in command, not powershell (without <)
"C:\Program Files\mongosh\mongosh.exe" -u "USER" -p "PASSWORD" --port YourPortNumber --authenticationDatabase "admin" < mongo_forDB_win10.js





