#!/bin/bash

. ../scripts/wait-for-network.sh

IMG=$(basename $(pwd))
CTR=tmp-$(uuidgen)

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

echo "installing PG packages..."
lxc exec $CTR -- yum -y install postgresql12-server postgresql12-contrib
lxc exec $CTR -- yum -y install https://www.cadc-ccda.hia-iha.nrc-cnrc.gc.ca/software/pgsphere12-1.2.0-1.el7.x86_64.rpm

lxc exec $CTR -- yum clean all

echo "stopping $CTR ..."
lxc stop $CTR

## publish container as a new image in local image store
echo "publishing $CTR ..."
lxc publish $CTR --alias $IMG description="Centos 7 amd64 / PG 12.x"

lxc delete $CTR
echo "published: $IMG"

