#!/bin/bash

LXC=incus
CTR=f42-build

PKGS=$($LXC exec $CTR -- find /usr/src/wcs -name \*JNI.so -type f)
for p in ${PKGS}; do
	echo $p 
	$LXC file pull ${CTR}${p} .
done

