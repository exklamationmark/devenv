FROM ubuntu:18.04

RUN apt-get update

# already have openssl

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y \
    tzdata \
    ca-certificates \
    wget \
    curl \
    make \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https

RUN apt-get install -y \
	openjdk-8-jre

RUN apt-get install -y \
	unzip \
	jq

ENV  VAULT_VERSION="0.10.3"
RUN curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
RUN unzip vault_${VAULT_VERSION}_linux_amd64.zip
RUN mv vault /usr/local/bin/
RUN vault --version

RUN apt-get install -y \
	netcat

RUN apt-get install -y \
	kafkacat

ADD scripts /var/run/scripts
