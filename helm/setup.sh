microk8s.kubectl create namespace tiller || kubectl create namespace tiller
microk8s.kubectl create -f rbac-config.yaml || kubectl create -f rbac-config.yaml
openssl genrsa -out ./ca.key.pem 4096
openssl req -key ca.key.pem -new -x509 -days 14 -sha256 -out ca.cert.pem -extensions v3_ca -subj "$SUBJ"
openssl genrsa -out ./tiller.key.pem 4096
openssl genrsa -out ./helm.key.pem 4096
openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem -subj "$SUBJ"
openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem -subj "$SUBJ"
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem -days 14
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem -days 14
mkdir -p $(helm home); cp ca.cert.pem $(helm home)/ca.pem; cp helm.cert.pem $(helm home)/cert.pem; cp helm.key.pem $(helm home)/key.pem
helm init --tiller-namespace tiller --service-account tiller --tiller-tls --tiller-tls-cert ./tiller.cert.pem --tiller-tls-key ./tiller.key.pem --tiller-tls-verify --tls-ca-cert ca.cert.pem
