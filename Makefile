all: local.infa
.PHONY: all

local.infa:
	CURDIR=${CURDIR} docker-compose -p devenv \
		--file docker-compose/cassandra.yml \
		--file docker-compose/prometheus.yml \
		up --force-recreate --renew-anon-volumes
PHONY: local.infa

local.destroy:
	CURDIR=${CURDIR} docker-compose -p devenv \
		--file docker-compose/cassandra.yml \
		--file docker-compose/prometheus.yml \
		down --volumes
	docker volume prune
PHONY: local.destroy
