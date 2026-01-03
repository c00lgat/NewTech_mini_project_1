#!/bin/bash

apt-get update && apt-get upgrade -y
apt-get install python3.11 python3-pip git

adduser app
mkdir app

git clone https://github.com/no3am/NewTech_DevOps_Nov25/tree/main/mini-project1

