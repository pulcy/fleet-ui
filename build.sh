#!/bin/bash
set -e

OS=`uname -o`
OS=linux
FLEET_VERSION=0.11.5
DOCKER_IMAGE_VERSION=${1:-"latest"}
export GOBIN=$GOPATH/bin

# echo
echo "OS - ${OS}"
echo "FLEET VERSION - ${FLEET_VERSION}"
echo "BUILD DOCKER IMAGE VERSION - ${DOCKER_IMAGE_VERSION}"

# install compass if not present
compass -v || (echo "Installing compass ruby gem..." && sudo gem install compass)

# build angular
cd angular
npm install
node_modules/bower/bin/bower install
node_modules/grunt-cli/bin/grunt build --force
cd ..

# build go app
go get -v
go install
cp $GOPATH/bin/fleeui tmp/fleet-ui

curl -L https://github.com/coreos/fleet/releases/download/v${FLEET_VERSION}/fleet-v${FLEET_VERSION}-linux-amd64.tar.gz | tar xz -C tmp/
cp tmp/fleet-v${FLEET_VERSION}-linux-amd64/fleetctl tmp/

docker build -t hub.crisidev.org:5000/crisidev/fleetui:$DOCKER_IMAGE_VERSION .
