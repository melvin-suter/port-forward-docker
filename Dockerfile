FROM alpine:3.21.3

LABEL MAINTAINER Cloud Platform <cloud.platform@digital.justice.gov.uk>

RUN apk add --update --no-cache socat \
	&& rm -rf /var/cache/apk/

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

ARG DEF_REMOTE_PORT=8000
ARG DEF_LOCAL_PORT=8000

ENV REMOTE_PORT=$DEF_REMOTE_PORT
ENV LOCAL_PORT=$DEF_LOCAL_PORT
ENV PROTO=tcp

## By default container listens on $LOCAL_PORT (8000)
EXPOSE 8000

USER 1001

CMD socat $PROTO-listen:$LOCAL_PORT,reuseaddr,fork $PROTO:$REMOTE_HOST:$REMOTE_PORT & pid=$! && trap "kill $pid" SIGINT && \
	echo "Socat started listening on $LOCAL_PORT/$PROTO: Redirecting traffic to $REMOTE_HOST:$REMOTE_PORT/$PROTO ($pid)" && wait $pid
