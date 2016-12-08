FROM ubuntu:16.04

ENV GOROOT /goroot
ENV GOPATH /go
ENV PATH $GOROOT/bin:$PATH
ENV APPLOC $GOPATH/src/github.com/finntech/ceph_exporter

RUN apt-get update && apt-get install -y apt-transport-https
RUN apt-get install -y build-essential git curl
RUN apt-get install -y --force-yes librados-dev librbd-dev

RUN \
  mkdir -p /goroot && \
  curl https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

ENV DOCKERIZE_VERSION v0.3.0
ENV DOCKERIZE_FILE dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
ENV DOCKERIZE_URL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/$DOCKERIZE_FILE
ENV DUMB_INIT https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64

RUN cd /tmp \
    && curl -sL -O $DOCKERIZE_URL \
    && tar -zxf $DOCKERIZE_FILE -C /usr/local/bin \
    && rm $DOCKERIZE_FILE \
    && cd -

ADD . $APPLOC
WORKDIR $APPLOC
RUN go get -d && \
    go build -o /bin/ceph_exporter

COPY etc/ceph/* /etc/ceph/
COPY entrypoint .

EXPOSE 9128
CMD ["./entrypoint"]
