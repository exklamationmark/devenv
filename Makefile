UID=$(shell id -u)
GID=$(shell id -g)
PREFIX=CURDIR=${CURDIR} UID=${UID} GID=${GID}
UUID=local

all: local.infra
.PHONY: all

clean:
	rm -rf .secrets
.PHONY: clean

.misc/cqlshrc:
	sed -e "s|\$$PWD|${CURDIR}|g" \
		< dockerfiles/tools/cqlsh/cqlshrc \
		> .misc/cqlshrc

local.infra: local.destroy
local.infra: CHAOS:=
local.infra:
	${PREFIX} docker-compose -p ${UUID} \
		--file docker-compose/vault.yml \
		up vault.locol.dev > /dev/null 2>/dev/null &
	sleep 10
	${PREFIX} docker-compose -p ${UUID} \
		--file docker-compose/init.yml \
		up --abort-on-container-exit init.locol.dev
ifeq (${CHAOS},true)
	echo "start chaotic monkey"
	${PREFIX} docker-compose -p ${UUID} \
		--file docker-compose/chaos.yml \
		up chaos.locol.dev > /dev/null 2>/dev/null &
endif
	${PREFIX} docker-compose -p ${UUID} \
		--file docker-compose/cassandra.yml \
		--file docker-compose/kafka.yml \
		--file docker-compose/elasticsearch.yml \
		--file docker-compose/prometheus.yml \
		up \
			cassandra-1.locol.dev \
			cassandra-2.locol.dev \
			cassandra-3.locol.dev \
			prometheus.locol.dev \
			zookeeper-1.locol.dev \
			zookeeper-2.locol.dev \
			zookeeper-3.locol.dev \
			kafka-1.locol.dev \
			kafka-2.locol.dev \
			kafka-3.locol.dev \
			elasticsearch-1.locol.dev \
			elasticsearch-2.locol.dev \
			elasticsearch-3.locol.dev \
			elasticsearch-exporter.locol.dev
PHONY: local.infra


local.destroy:
	${PREFIX} docker-compose -p ${UUID} \
		--file docker-compose/chaos.yml \
		--file docker-compose/init.yml \
		--file docker-compose/vault.yml \
		--file docker-compose/cassandra.yml \
		--file docker-compose/kafka.yml \
		--file docker-compose/elasticsearch.yml \
		--file docker-compose/prometheus.yml \
		down --volumes
PHONY: local.destroy

build.tools:
	docker build --rm \
		--tag=locol.dev/tools:latest \
		dockerfiles/tools
.PHONY: build.tools
