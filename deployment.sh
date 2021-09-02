#!/bin/bash

source $HOME/node-web-app/.env

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
            cd $HOME/node-web-app
            docker-compose stop nodeapp
            docker-compose rm -f
            #docker rm -f $container1 $container2
            #docker rmi -f $imageID
        fi
    fi
fi

docker-compose -f $HOME/node-web-app/prod.docker-compose.yaml up -d --scale nodeapp=2 --force-recreate