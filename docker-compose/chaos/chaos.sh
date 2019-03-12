#!/bin/sh

# simple script that randomly turn restart containers

# stop duration, in seconds
MIN_DUR=20
MAX_DUR=120

# interval between restarts, in seconds
CHAOS_INTERVAL=180

restart_one() {
	local info="$(docker ps --filter "label=chaos=true" --format '{{.ID}} {{.Names}}' | grep -v chaos | shuf -n 1)"
	local id=$(echo $info | awk '{print $1}')
	local name=$(echo $info | awk '{print $2}')
	local duration=$(shuf -i $MIN_DUR-$MAX_DUR -n 1)

	echo "docker stop $name ($id)"
	echo "Ta be, or not ta be, dat iz da question now!"
	docker stop $id
	echo "sleep $duration"
	sleep $duration
	echo "docker start $name ($id)"
	docker start $id
}

echo "imma chaotic mon-keigh-ork!"

# establish some baseline for 5m+
echo "need ta wait for 5m+ ta have a baseline"
sleep 330

while true
do
	restart_one
	sleep $CHAOS_INTERVAL
done
