#!/bin/sh -l

# Build docker image from docker-compose.yml
ls -la
cat docker-compose.yml

## Not supported at the moment
# docker-compose --verbose build

## Workarond
#xservice=`cat package.json | envsubst|jq '.name'|awk '{system("echo "$1)}'|awk '/START/{if (NR!=1)print " ";next}{printf $0" "}END{print " ";}'|cut -c2-`

### js-yaml docker-compose.yml| envsubst |jq '.services|to_entries[].key'
### js-yaml docker-compose.yml| envsubst |jq '.services|keys[]'

for xservice in $(js-yaml docker-compose.yml| envsubst |jq -r '.services|keys[]'); do

    xbuild=`js-yaml docker-compose.yml| envsubst |jq --arg xservice "$xservice" '.services[$xservice].build'`
    if [ "${xbuild}" != "null" ]; then
        echo "*******************************"
        echo "******* Publishing: ${xservice}"
        echo "*******************************"
        ximg=`js-yaml docker-compose.yml| envsubst |jq --arg xservice "$xservice" '.services[$xservice].image'|awk '{system("echo "$1)}'|awk '/START/{if (NR!=1)print " ";next}{printf $0" "}END{print " ";}'`
        
        xarg=`js-yaml docker-compose.yml| envsubst |jq --arg xservice "$xservice" '.services[$xservice].build.args'`
        if [ "${args}" != "null" ]; then
            xarg=`js-yaml docker-compose.yml| envsubst |jq --arg xservice "$xservice" '.services[$xservice].build.args[]'|awk '{system("echo "$1)}'|awk '/START/{if (NR!=1)print " ";next}{printf "--build-arg "$0"  "}END{print " ";}'`
        else
            xarg=""
        fi;

        command="docker push ${xarg}"
        echo "COMMAND: ${command}"
        echo ${command}| sh -
    fi;
done