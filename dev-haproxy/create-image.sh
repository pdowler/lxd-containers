#!/bin/bash

. ../scripts/wait-for-network.sh

IMG=dev-haproxy
IMGFILE=${IMG}.tar.gz
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
lxc exec $CTR -- yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

echo "updating $CTR ..."
lxc exec $CTR -- yum -y update

echo "installing haproxy ..."
lxc exec $CTR -- yum -y install haproxy

echo "inject custom systemd unit for HAProxy to enable x509 proxy certificates"
lxc exec $CTR mkdir /etc/systemd/system/haproxy.service.d
lxc file push system/override.conf $CTR/etc/systemd/system/haproxy.service.d/

echo "inject extra CA certficates"
for cf in ca-trust/*.*; do
    echo "inject CA: $cf"
    lxc file push $cf $CTR/etc/pki/ca-trust/source/anchors/
done
lxc exec $CTR update-ca-trust

for cf in config/*.*; do 
    echo "inject config: $cf"
    lxc file push $cf $CTR/etc/haproxy/
done

echo "enable HAproxy at next boot"
lxc exec $CTR systemctl enable haproxy

lxc exec $CTR -- yum clean all

#echo "stopping $CTR ..."
lxc stop $CTR

## publish container as a new image in local image store
echo "publishing $CTR ..."
lxc publish $CTR --alias $IMG description="Centos 7 + HAProxy"
lxc delete $CTR
echo "published: $IMG"



