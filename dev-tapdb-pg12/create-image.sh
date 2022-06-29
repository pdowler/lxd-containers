#!/bin/bash

. ../scripts/wait-for-network.sh

BASEIMG=base-pg12
IMG=dev-tapdb-pg12
IMGFILE=${IMG}.tar.gz
CTR=tmp-$(uuidgen)


echo "create $CTR from $BASEIMG"
lxc init $BASEIMG $CTR
lxc start $CTR

waitForNetwork $CTR

echo "inject dev PostgreSQL configuration files into container"
for f in config/*.*; do 
    lxc file push $f $CTR/var/lib/pgsql/12/
done

echo "inject systemd unit to perform init at first boot"
for f in pgdb-init/*.sh; do
    lxc file push $f $CTR/usr/local/bin/
done
lxc file push pgdb-init/pgdb-init.service $CTR/usr/lib/systemd/system/
lxc exec $CTR systemctl enable pgdb-init.service

#echo "stop $CTR ..."
lxc stop $CTR

#echo "publish $CTR ..."
lxc publish $CTR --alias $IMG description="PG 12.x with pgdb-init"
lxc delete $CTR

