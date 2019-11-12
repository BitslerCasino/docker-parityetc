FROM bitsler/wallet-base:latest

ARG version
ENV WALLET_VERSION=$version
ENV HOME /etclassic

ENV USER_ID 1000
ENV GROUP_ID 1000

RUN groupadd -g ${GROUP_ID} etclassic \
  && useradd -u ${USER_ID} -g etclassic -s /bin/bash -m -d /etclassic etclassic \
  && set -x \
  && apt-get update -y \
  && apt-get install -y sudo \
  && /bin/bash -c "bash <(curl https://get.parity.io -L) -r $version" \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/etc_oneshot

VOLUME ["/etclassic"]

EXPOSE 8546 30304

WORKDIR /etclassic

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["etc_oneshot"]