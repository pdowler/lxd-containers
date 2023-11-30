#!/bin/bash

. ../scripts/wait-for-network.sh

CTR=f38-build

lxc list $CTR | grep -q $CTR
if [ $? == 0 ]; then
	echo "found: $CTR"
else
	lxc init images:fedora/38 $CTR 
	echo "created: $CTR"
fi

# must be running to install and configure
echo "starting $CTR ..."
lxc start $CTR 

waitForNetwork $CTR

echo "adding yum repos..."
lxc exec $CTR -- dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/F-38-x86_64/pgdg-fedora-repo-latest.noarch.rpm

echo "installing packages..."
lxc exec $CTR -- dnf -y install which rpm-build rpmdevtools rpmlint make clang gcc gcc-c++ ccache git bison flex
lxc exec $CTR -- rpmdev-setuptree

echo "done build system setup"
exit

echo "installing pgsphere dependencies..."
lxc exec $CTR -- dnf -y install postgresql15-devel libpq-devel healpix-c++-devel zlib-devel
lxc exec $CTR -- mkdir -p /usr/lib64/pgsql/
lxc exec $CTR -- ln -s /usr/pgsql-15/lib/pgxs /usr/lib64/pgsql/pgxs

echo "spec file template -> /root/rpmbuild/pgsphere-PGSVER.spec"
lxc file push pgsphere-PGSVER.spec $CTR/root/rpmbuild/pgsphere-PGSVER.spec

echo "$CTR is ready"
echo "usage: lxc exec $CTR bash"

