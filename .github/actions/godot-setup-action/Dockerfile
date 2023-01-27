
FROM alpine:3.14
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && ls -lsa /
ENTRYPOINT ["/entrypoint.sh"]