#!/bin/bash

. ../scripts/wait-for-network.sh

CTR=haproxy-f40

incus list $CTR | grep -q $CTR
if [ $? == 0 ]; then
	echo "found: $CTR"
else
	incus init images:fedora/40 $CTR
	echo "created: $CTR"
fi

# must be running to install and configure
echo "starting $CTR ..."
incus start $CTR

waitForNetwork $CTR

echo "installing haproxy ..."
incus exec $CTR -- dnf -y install haproxy
incus exec $CTR -- dnf clean all

echo "inject config: $cf"
cat config/haproxy.cfg config/haproxy-rules.conf config/haproxy-backends.conf > tmp.cfg
incus file push tmp.cfg $CTR/etc/haproxy/haproxy.cfg
\rm tmp.cfg

incus file push $HOME/work/dev-server-cert.pem $CTR/etc/haproxy/

echo "adding CA certs"
for f in $HOME/work/etc/cacerts/*; do
  incus file push $f $CTR/etc/pki/ca-trust/source/anchors/
done
incus exec $CTR update-ca-trust

echo "enable HAproxy"
incus exec $CTR systemctl enable haproxy
incus exec $CTR systemctl start haproxy

incus exec $CTR systemctl status haproxy



