#!/bin/bash

yum -y update 
amazon-linux-extras install docker
yum -y install docker
service docker start
usermod -a -G docker ec2-user
sleep 10

docker run -t -p 8089:8089 -p 5557:5557 -p 5558:5558 ${image} ${params}
