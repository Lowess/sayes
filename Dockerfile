FROM nginx

ADD default.conf /etc/nginx/conf.d/default.conf

RUN apt-get update \
  && apt-get -y install wget curl jq \
  && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

RUN wget -O /usr/local/bin/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 \
    && chmod +x /usr/local/bin/dumb-init /entrypoint.sh

ADD metadata.json /metadata.json

ENTRYPOINT ["/usr/local/bin/dumb-init", "-v", "--"]
CMD ["/entrypoint.sh"]
