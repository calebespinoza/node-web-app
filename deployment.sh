#!/bin/bash

cd $HOME/node-web-app

echo "Retrieving the Container ID if exits"
container1=$(docker ps --filter status=running --filter name=node-web-app* -q | head -n 1)
container2=$(docker ps --filter status=running --filter name=node-web-app* -q | tail -1)

if [ ! -z $container1 -a ! -z $container2 ];
then
    echo "Container 1 = $container1"
    echo "Container 2 = $container2"
    echo "Retrieving the Image Name associated to the container"
    imageName=$(docker inspect --format='{{.Config.Image}}' $container1)
    echo "ImageName = $imageName"
    if [ $imageName ];
    then
        imageID=$(docker inspect --format='{{.Id}}' $imageName)
        if [ $imageID ];
        then
            docker-compose -f prod.docker-compose.yaml stop
            docker-compose -f prod.docker-compose.yaml rm -f
            docker-compose -f prod.docker-compose.yaml pull
            #docker rm -f $container1 $container2
            #docker rmi -f $imageID
        fi
    fi
fi
# Deploying
docker-compose -f prod.docker-compose.yaml up -d --scale nodeapp=2 --force-recreate
