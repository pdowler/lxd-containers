# base-pg12 

Just the software: HAProxy with basic config to support a dev/test system.

* https only; but requires SSL cert to be added
* client proxy certificate support; client cert forwarded via http header to back end

Build image, start container, `lxc exec {container} bash`, vi /etc/haproxy/haproxy.cfg,
`systemctl restart haproxy`, ...

