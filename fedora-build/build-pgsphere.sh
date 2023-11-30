#!/bin/bash

## code to be run inside the container -- probably manually ##

# clone source repo
cd /usr/src
git clone https://github.com/postgrespro/pgsphere.git
cd pgsphere
git fetch --tags --all
git tag -l

PGSVER=1.4.1

# build source taballs
cd /usr/src
cd pgsphere
git checkout tags/${PGSVER} -b v${PGSVER}
# fix the dist target
vi Makefile
make dist
# unfix
git checkout -- Makefile
git checkout master
cd ..
cp pgsphere-${PGSVER}.tar.gz /root/rpmbuild/SOURCES/

# edit spec templates
cd /root/rpmbuild
cp pgsphere-PGSVER.spec SPECS/pgsphere-${PGSVER}.spec
vi SPECS/pgsphere-${PGSVER}.spec

## install (-bi) to figure out current files, then build package (-bb)
QA_RPATHS=$((0x0002)) rpmbuild -bi /root/rpmbuild/SPECS/pgsphere-${PGSVER}.spec
pushd /root/rpmbuild/BUILDROOT/pgsphere15-${PGSVER}-1.fc38.x86_64/usr
find pgsql-15 -type f | sed 's/pgsql-15/%{pginstdir}/g' >> /root/rpmbuild/SPECS/pgsphere-${PGSVER}.spec
popd
## make the package and cleanup
QA_RPATHS=$((0x0002)) rpmbuild -bb /root/rpmbuild/SPECS/pgsphere-${PGSVER}.spec

# list output
find /root/rpmbuild



