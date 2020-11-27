#!/bin/bash

echo fs.file-max = 512000 >>  /etc/sysctl.conf
sysctl -p

cat << EOF > /etc/security/limits.conf
*               soft    nofile          65000
*               hard    nofile          65000
*               soft    nproc           10240
*               hard    nproc           10240
EOF

yum -y update 
amazon-linux-extras install docker
yum -y install docker
service docker start
usermod -a -G docker ec2-user
sleep 10

docker run --ulimit nofile=10240:10240 -t ${image} ${params}
