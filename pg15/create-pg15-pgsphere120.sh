#!/bin/bash

. ../scripts/wait-for-network.sh

IMG=pg15-pgsphere120
CTR=tmp-$(uuidgen)

lxc list $CTR | grep -q $CTR
if [ $? == 0 ]; then
	echo "found: $CTR"
else
	lxc init images:fedora/37 $CTR 
	echo "created: $CTR"
fi

# must be running to install and configure
echo "starting $CTR ..."
lxc start $CTR 

waitForNetwork $CTR

echo "adding yum repos..."
lxc exec $CTR -- dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/F-37-x86_64/pgdg-fedora-repo-latest.noarch.rpm

echo "installing PG packages..."
lxc exec $CTR -- dnf -y install postgresql15-server postgresql15-contrib

lxc exec $CTR -- dnf -y install https://ws-cadc.canfar.net/vault/files/pdowler/rpms/pgsphere15-1.2.0-1.fc37.x86_64.rpm

lxc exec $CTR -- dnf -y clean all

PG=$(lxc exec $CTR -- rpm -q --queryformat "%{NAME}-%{VERSION}" postgresql15-server)
PGS=$(lxc exec $CTR -- rpm -q --queryformat "%{NAME}-%{VERSION}" pgsphere15)
DESC="${PG} / ${PGS}"

echo "adding developer pg-init..."
../pg15-init/add-to-image.sh $CTR

echo "stopping $CTR ..."
lxc stop $CTR

## publish container as a new image in local image store
echo "publishing $CTR ..."
lxc publish $CTR --alias $IMG description="${DESC}"

lxc delete $CTR
echo "published: $IMG"

