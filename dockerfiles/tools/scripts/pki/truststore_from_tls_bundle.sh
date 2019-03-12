#!/bin/sh

clean() {
	rm -f $FOLDER/$NAME/truststore.jks
	rm -f $FOLDER/$NAME/truststore.p12
}

create_truststore() {
	keytool -importcert -noprompt \
		-alias $CA_NAME \
		-keystore $FOLDER/$NAME/truststore.jks \
		-file $FOLDER/$NAME/ca-certificate.pem \
		-storepass $PASSWORD

	# keytool -list -keystore .secrets/cassandra-1.locol.dev.truststore.jks -storepass $PASSWORD

	keytool -importkeystore \
		-srckeystore $FOLDER/$NAME/truststore.jks \
		-srcstoretype jks \
		-srcstorepass $PASSWORD \
		-destkeystore $FOLDER/$NAME/truststore.p12 \
		-deststoretype pkcs12 \
		-deststorepass $PASSWORD

	# keytool -list -keystore $FOLDER/$NAME/truststore.p12 -storepass $PASSWORD

	echo -n "$PASSWORD" > $FOLDER/$NAME/truststore.password

}

# ----------------------------------------

FOLDER=${1%/}
NAME=$2
PASSWORD=$3
# VAULT_ADDR: take from env
# VAULT_TOKEN: take from env
CA_NAME="ca-certificate"

clean
create_truststore
