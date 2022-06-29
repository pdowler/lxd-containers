#!/bin/bash

. ../scripts/wait-for-network.sh

CTR=centos7-build

lxc list $CTR | grep -q $CTR
if [ $? == 0 ]; then
	echo "found: $CTR"
else
	lxc init images:centos/7 $CTR 
	echo "created: $CTR"
fi

# must be running to install and configure
echo "starting $CTR ..."
lxc start $CTR 

waitForNetwork $CTR

echo "adding yum repos..."
lxc exec $CTR -- yum -y install centos-release-scl
lxc exec $CTR -- yum -y install epel-release 

lxc exec $CTR -- yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
lxc exec $CTR -- rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG

echo "installing packages..."
lxc exec $CTR -- yum -y install which yum-utils rpm-build rpmdevtools rpmlint make gcc gcc-c++ 
lxc exec $CTR -- rpmdev-setuptree

