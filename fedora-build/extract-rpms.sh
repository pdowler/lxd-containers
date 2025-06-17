#!/bin/bash

LXC=incus
CTR=f42-build

PKGS=$($LXC exec $CTR -- find /root/rpmbuild/RPMS -type f | grep -v debug)
for rpm in ${PKGS}; do
	echo $rpm
	$LXC file pull ${CTR}${rpm} .
done

