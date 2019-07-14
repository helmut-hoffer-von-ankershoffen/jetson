#!/bin/sh

echo "Checking docker daemon settings..."

if docker info | grep --quiet "max-one.localhost"; then
	echo "... already in place."
else
    mkdir -p ~/.docker || true
	cp -f ./daemon.json ~/.docker/daemon.json
	osascript -e 'quit app "Docker"' && open --background -a Docker
	echo "... changed config and restarted docker."
fi
