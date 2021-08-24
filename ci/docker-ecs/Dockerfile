#####  Build container  #####

FROM --platform=linux/amd64 golang:buster as builder 

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # Common
    curl \
    # Protoc
    protobuf-compiler \
    libprotobuf-dev 



# Starport
RUN curl https://get.starport.network/starport! | bash


# App
WORKDIR /app

COPY app ./app
COPY cmd ./cmd
COPY proto ./proto
COPY vue ./vue
COPY x ./x
COPY go.mod .
COPY go.sum .
   

#RUN starport chain build

RUN apt-get update && apt-get logrotate
COPY cheqd-node_0.1.17_amd64.deb .
RUN dpkg -i cheqd-node_0.1.17_amd64.deb

#####  Run container  #####

FROM --platform=linux/amd64 debian:buster

#COPY --from=builder /go/bin/cheqd-noded /bin

COPY node-runner.sh /bin/node-runner

RUN chmod +x /bin/node-runner

#RUN groupadd --gid 1000 cheqd && \
#    useradd --create-home --shell /bin/bash --uid 1000 --gid cheqd cheqd

WORKDIR /home/cheqd
USER cheqd

VOLUME /home/cheqd/.cheqdnode
EXPOSE 26656 26657
STOPSIGNAL SIGTERM

ENTRYPOINT [ "cheqd-noded" ]
