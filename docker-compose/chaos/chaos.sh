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
	docker stop $id
	echo "sleep $duration"
	sleep $duration
	echo "docker start $name ($id)"
	docker start $id
}

echo "Hello, chaos!"
while true
do
	sleep $CHAOS_INTERVAL
	restart_one
done
