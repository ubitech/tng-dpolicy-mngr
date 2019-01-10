#!/bin/bash
set -e
mvn clean install
docker build -t registry.sonata-nfv.eu:5000/tng-dpolicy-mngr . 
