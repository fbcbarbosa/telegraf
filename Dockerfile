FROM golang:1.9.4
WORKDIR /go/src/github.com/influxdata/telegraf
ADD . .
RUN make deps && make telegraf

FROM alpine:3.6

RUN echo 'hosts: files dns' >> /etc/nsswitch.conf && \
    apk add --no-cache iputils ca-certificates net-snmp-tools procps && \
    update-ca-certificates

COPY --from=0 /go/src/github.com/influxdata/telegraf/telegraf /usr/bin/telegraf
RUN mkdir -p /etc/telegraf && \
    chmod +x /usr/bin/telegraf

EXPOSE 8125/udp 8092/udp 8094

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]
