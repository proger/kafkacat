FROM debian:stretch-slim as builder

ARG librdkafka_version=v0.11.1
ARG yajl_version=2.1.0

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

RUN runtimeDeps='libssl1.1 libsasl2-2'; \
  buildDeps='curl ca-certificates build-essential zlib1g-dev liblz4-dev libssl-dev libsasl2-dev python cmake libcurl3-dev libjansson-dev autoconf automake libtool'; \
  apt-get install -y $runtimeDeps $buildDeps --no-install-recommends

COPY . /usr/src/kafkacat

RUN set -ex; cd /usr/src/kafkacat; \
  \
  sed -i "s|github_download \"edenhill/librdkafka\" \"master\"|github_download \"edenhill/librdkafka\" \"${librdkafka_version}\"|" ./bootstrap.sh; \
  sed -i "s|github_download \"lloyd/yajl\" \"master\"|github_download \"lloyd/yajl\" \"${yajl_version}\"|" ./bootstrap.sh; \
  \
  echo "Source versions:"; \
  grep ^github_download ./bootstrap.sh; \
  \
  ./bootstrap.sh; \
  mv ./kafkacat /usr/local/bin/

FROM debian:stretch-slim as run

RUN apt-get update; apt-get install -y libssl1.1 libsasl2-2 curl jq
COPY --from=builder /usr/local/bin/kafkacat  /usr/local/bin/

ENTRYPOINT ["kafkacat"]
