#!/bin/bash

LXC=incus

. ../scripts/wait-for-network.sh

CTR=f42-build

$LXC list $CTR | grep -q $CTR
if [ $? == 0 ]; then
	echo "found: $CTR"
else
	$LXC init images:fedora/42 $CTR 
	echo "created: $CTR"
fi

# must be running to install and configure
echo "starting $CTR ..."
$LXC start $CTR 

waitForNetwork $CTR

echo "adding yum repos..."
$LXC exec $CTR -- dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/F-42-x86_64/pgdg-fedora-repo-latest.noarch.rpm

echo "installing dev tools..."
$LXC exec $CTR -- dnf -y install which rpm-build rpmdevtools rpmlint make clang gcc gcc-c++ ccache git bison flex 
$LXC exec $CTR -- dnf -y install java-21-openjdk-headless java-21-openjdk-devel
$LXC exec $CTR -- rpmdev-setuptree

## gradle wrapper included in source repos

echo "installing devel dependencies..."
$LXC exec $CTR -- dnf -y install postgresql15-devel libpq5-devel healpix-c++-devel zlib-devel wcslib-devel erfa-devel
$LXC exec $CTR -- mkdir -p /usr/lib64/pgsql/
$LXC exec $CTR -- ln -s /usr/pgsql-15/lib/pgxs /usr/lib64/pgsql/pgxs

echo "spec file template -> /root/rpmbuild/pgsphere-PGSVER.spec"
$LXC file push pgsphere-PGSVER.spec $CTR/root/rpmbuild/pgsphere-PGSVER.spec

echo "$CTR is ready"
echo "usage: $LXC exec $CTR bash"

