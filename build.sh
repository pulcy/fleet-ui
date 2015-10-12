#!/bin/sh
set -e

OS=`uname -o`
OS=linux
FLEET_VERSION=0.10.2
DOCKER_IMAGE_VERSION=${1:-"latest"}

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
node_modules/grunt-cli/bin/grunt build
cd ..

# build go app
go get -v
go install
cp $GOPATH/bin/fleet-ui tmp/

if [ ${OS} == "Darwin" ]; then
    curl -L https://github.com/coreos/fleet/releases/download/v${FLEET_VERSION}/fleet-v${FLEET_VERSION}-darwin-amd64.zip > tmp/fleet-v${FLEET_VERSION}-darwin-amd64.zip && \
        unzip tmp/fleet-v${FLEET_VERSION}-darwin-amd64.zip && \
        rm tmp/fleet-v${FLEET_VERSION}-darwin-amd64.zip
        cp tmp/fleet-v${FLEET_VERSION}-darwin-amd64/fleetctl tmp/
else
    curl -L https://github.com/coreos/fleet/releases/download/v${FLEET_VERSION}/fleet-v${FLEET_VERSION}-linux-amd64.tar.gz | tar xz -C tmp/
    cp tmp/fleet-v${FLEET_VERSION}-linux-amd64/fleetctl tmp/
fi

#docker build -t purpleworks/fleet-ui:$DOCKER_IMAGE_VERSION .
