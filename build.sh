#!/bin/sh
set -e

FLEET_VERSION=0.10.2
DOCKER_IMAGE_VERSION=${1:-"latest"}

# echo
echo "FLEET VERSION - "$FLEET_VERSION
echo "BUILD DOCKER IMAGE VERSION - "$DOCKER_IMAGE_VERSION

# build angular
cd angular
npm install
node_modules/bower/bin/bower install
node_modules/grunt-cli/bin/grunt build
cd ..

# build go app
go get -v
go install
cp $GOPATH/bin/fleet-ui tmp/
curl -s -L https://github.com/coreos/fleet/releases/download/v${FLEET_VERSION}/fleet-v${FLEET_VERSION}-linux-amd64.tar.gz | \
  tar xz fleet-v${FLEET_VERSION}-linux-amd64/fleetctl -O > tmp/fleetctl
chmod +x tmp/fleetctl
docker build -t purpleworks/fleet-ui:$DOCKER_IMAGE_VERSION .
