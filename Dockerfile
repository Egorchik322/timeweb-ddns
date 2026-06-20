FROM alpine:3.20

RUN apk add --no-cache bash curl jq ca-certificates

COPY timeweb-ddns.sh /usr/local/bin/timeweb-ddns.sh
RUN chmod +x /usr/local/bin/timeweb-ddns.sh

CMD ["/usr/local/bin/timeweb-ddns.sh"]
