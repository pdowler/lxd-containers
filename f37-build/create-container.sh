#!/bin/bash

. ../scripts/wait-for-network.sh

CTR=$(basename $(pwd))

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

echo "installing packages..."
lxc exec $CTR -- dnf -y install which rpm-build rpmdevtools rpmlint make gcc gcc-c++ ccache 
lxc exec $CTR -- rpmdev-setuptree

if [ -f pgsphere-1.2.0.tar.gz ]; then
	echo "installing pgsphere dependencies..."
	lxc exec $CTR -- dnf -y install postgresql15-devel healpix-c++-devel zlib-devel

	lxc file push pgsphere.spec $CTR/root/rpmbuild/SPECS/pgsphere-1.2.0.spec
	lxc file push pgsphere-1.2.0.tar.gz $CTR/root/rpmbuild/SOURCES/pgsphere-1.2.0.tar.gz

	echo "building pgsphere package..."
	lxc exec $CTR -- QA_RPATHS=$((0x0002)) rpmbuild -bb /root/rpmbuild/SPECS/pgsphere-1.2.0.spec
	lxc file pull $CTR/root/rpmbuild/RPMS/x86_64/pgsphere15-1.2.0-1.fc37.x86_64.rpm
else
	echo "not found: pgsphere-1.2.0.tar.gz"
fi
