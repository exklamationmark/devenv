#!/bin/sh
set -e

clean() {
	rm -rf $FOLDER/$NAME
	mkdir -p $FOLDER/$NAME
}

fetch_keypair() {
	local temp_file=$(mktemp)

	VAULT_ADDR=$VAULT_ADDR \
	VAULT_TOKEN=$VAULT_TOKEN \
	vault write pki/issue/locol-dot-dev \
		common_name=$NAME --format=json > $temp_file

	jq -r ".data.certificate" < $temp_file > $FOLDER/$NAME/certificate.pem
	jq -r ".data.issuing_ca" < $temp_file > $FOLDER/$NAME/ca-certificate.pem
	jq -r ".data.private_key" < $temp_file > $FOLDER/$NAME/key.pem

	rm $temp_file
}

create_keystore() {
	local temp_pkcs12=$(mktemp)

	openssl pkcs12 -export \
		-in $FOLDER/$NAME/certificate.pem \
		-inkey $FOLDER/$NAME/key.pem \
		-name $NAME \
		-out $temp_pkcs12 \
		-passout "pass:$PASSWORD"

	keytool -importkeystore \
		-srckeystore $temp_pkcs12 \
		-srcstoretype pkcs12 \
		-srcstorepass $PASSWORD \
		-destkeystore $FOLDER/$NAME/keystore.jks \
		-deststoretype jks \
		-deststorepass $PASSWORD

	rm $temp_pkcs12
	# keytool -list -keystore $FOLDER/$NAME/keystore.jks -storepass $PASSWORD

	keytool -import -noprompt \
		-alias $CA_NAME \
		-trustcacerts \
		-file $FOLDER/$NAME/ca-certificate.pem \
		-keystore $FOLDER/$NAME/keystore.jks \
		-storepass $PASSWORD

	# keytool -list -keystore $FOLDER/$NAME/keystore.jks -storepass $PASSWORD

	keytool -importkeystore \
		-srckeystore $FOLDER/$NAME/keystore.jks \
		-srcstoretype jks \
		-srcstorepass $PASSWORD \
		-destkeystore $FOLDER/$NAME/keystore.p12 \
		-deststoretype pkcs12 \
		-deststorepass $PASSWORD

	# keytool -list -keystore $FOLDER/$NAME/keystore.p12 -storepass $PASSWORD

	echo -n "$PASSWORD" > $FOLDER/$NAME/keystore.password
	echo -n "$PASSWORD" > $FOLDER/$NAME/key.password
}

# ----------------------------------------

FOLDER=${1%/}
NAME=$2
PASSWORD=$3
# VAULT_ADDR: take from env
# VAULT_TOKEN: take from env
CA_NAME="ca-certificate"

clean
fetch_keypair
create_keystore
