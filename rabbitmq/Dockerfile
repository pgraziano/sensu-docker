FROM rabbitmq:3

COPY init.sh /init.sh
COPY rabbitmq.config /etc/rabbitmq/rabbitmq.config
RUN chmod 0755 /init.sh
CMD ["/init.sh"]
