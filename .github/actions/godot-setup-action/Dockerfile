
FROM alpine:3.14
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && apk update && apk upgrade && apk add curl
ENTRYPOINT ["/entrypoint.sh"]