#!/bin/bash

yum -y update 
amazon-linux-extras install docker
yum -y install docker
service docker start
usermod -a -G docker ec2-user
sleep 10

docker run -t ${image} ${params}
