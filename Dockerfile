FROM alpine:3.9

ENV TIKA_VERSION 1.24.1
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

RUN apk add \
    --update \
    --no-cache \
    coreutils \
    bash \
    openjdk8-jre \
    gnupg \
    curl

RUN curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc
RUN gpg --import /tmp/tika.asc
RUN curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server.jar.asc
RUN MIRROR_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
		| awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
		| sed -r -e 's/^"//; s/",$//; s/" "//') \
	&& echo "Downloading Tika Server from: $MIRROR_TIKA_SERVER_URL" \
	&& curl -sSL "$MIRROR_TIKA_SERVER_URL" -o /tika-server.jar

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY start-server /usr/local/bin/tika-server

EXPOSE 9998
ENTRYPOINT tika-server
