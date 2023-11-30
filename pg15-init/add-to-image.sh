#!/bin/bash

SRC=$(dirname $0)
CTR=$1

echo "inject dev PostgreSQL configuration files into container"
for f in $SRC/config/*.*; do 
    lxc file push $f $CTR/var/lib/pgsql/15/
done

echo "inject systemd unit to perform init at first boot"
for f in $SRC/pgdb-init/*.sh; do
    lxc file push $f $CTR/usr/local/bin/
done
lxc file push $SRC/pgdb-init/pgdb-init.service $CTR/usr/lib/systemd/system/
lxc exec $CTR systemctl enable pgdb-init.service

