#!/bin/bash

CTR=f38-build

PKGS=$(lxc exec $CTR -- find /root/rpmbuild/RPMS -type f | grep -v debug)
for rpm in ${PKGS}; do
	echo $rpm
	lxc file pull ${CTR}${rpm} .
done

