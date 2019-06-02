FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y wget apt-utils apt-transport-https vim net-tools curl less \
  && wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add - \
  && echo "deb     https://sensu.global.ssl.fastly.net/apt xenial main" | tee /etc/apt/sources.list.d/sensu.list \
  && apt-get update \
  && apt-get install -y sensu supervisor uchiwa \
  && mkdir -p /var/log/supervisor

# configs
COPY conf.d /etc/sensu/conf.d
COPY uchiwa.json /etc/sensu/uchiwa.json
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sensu-cli /etc/sensu/sensu-cli

# gem dependencies and sensu-cli
RUN /opt/sensu/embedded/bin/gem install sensu-plugin sensu-plugins-pagerduty sensu-cli \
  && ln -s /opt/sensu/embedded/bin/sensu-cli /usr/local/bin/

# permission fixes
RUN chown -R sensu:sensu /etc/sensu

CMD ["/usr/bin/supervisord"]
