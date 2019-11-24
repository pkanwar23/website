# Container image that runs your code
FROM alpine:latest

RUN	apk add --no-cache \
	bash \
	ca-certificates \
	curl \
	ssd \
	git

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
# COPY empty.sh /empty.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT ["/empty.sh"]
