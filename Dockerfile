FROM ubuntu:xenial

ENV HOME /etc

ENV USER_ID 1000
ENV GROUP_ID 1000

RUN groupadd -g ${GROUP_ID} etc \
  && useradd -u ${USER_ID} -g etc -s /bin/bash -m -d /etc etc \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu sudo \
  && /bin/bash -c "bash <(curl https://get.parity.io -L) -r stable" \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/etc_oneshot

VOLUME ["/etc"]

EXPOSE 8546 30304

WORKDIR /etc

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["etc_oneshot"]