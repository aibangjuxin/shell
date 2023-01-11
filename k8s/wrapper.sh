#!/bin/bash
#base ubuntu package to build unbound and nginx
#https://docs.docker.com/config/containers/multi-service_container/
/usr/sbin/nginx -V
/usr/sbin/nginx &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi
/usr/sbin/unbound-anchor -a /var/lib/unbound/root.key
/usr/sbin/unbound
tail -f /dev/null
