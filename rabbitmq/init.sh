#!/bin/sh

# Create Rabbitmq user
( sleep 20 ; \
rabbitmqctl add_vhost /sensu ; \
rabbitmqctl add_user $RABBIT_SENSU_USER $RABBIT_SENSU_PASS 2>/dev/null ; \
rabbitmqctl set_user_tags $RABBIT_SENSU_USER administrator ; \
rabbitmqctl set_permissions -p /sensu $RABBIT_SENSU_USER  ".*" ".*" ".*" ; ) &

rabbitmq-server $@
