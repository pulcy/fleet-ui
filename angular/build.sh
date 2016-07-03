#!/bin/bash
set -e

npm install
node_modules/bower/bin/bower install
node_modules/grunt-cli/bin/grunt build --force

cp -r dist/bower_components/font-awesome/fonts dist/
