# Compile image
ARG GO_VERSION=1.8.1  
FROM golang:${GO_VERSION}-alpine AS build-stage
MAINTAINER Dave (Daviey) Walker <email@daviey.com>

WORKDIR /go/src/github.com/gophish/gophish/ 
COPY ./ /go/src/github.com/gophish/gophish/

RUN apk add --update --no-cache \
  gcc \
  g++ \
  git

RUN go get -d &&\
  go build

# Runtime image
FROM alpine:3.5  
MAINTAINER Dave (Daviey) Walker <email@daviey.com>

ARG SRC=/go/src/github.com/gophish/gophish
COPY --from=build-stage \
  ${SRC}/gophish \
  ${SRC}/VERSION \
  ${SRC}/config.json \
  ./

COPY --from=build-stage \
  ${SRC}/static \
  ./static/

COPY --from=build-stage \
  ${SRC}/templates \
  ./templates/


RUN sed -i "s|127.0.0.1|0.0.0.0|g" config.json 

EXPOSE 3333 80
ENTRYPOINT ["/gophish"]  
