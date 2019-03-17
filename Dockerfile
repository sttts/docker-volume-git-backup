FROM __BASEIMAGE_ARCH__/debian:stretch

MAINTAINER fvanderbiest "francois.vanderbiest@gmail.com"

RUN apt-get update && \
    apt-get install -y git inotify-tools && \
		rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/man/*

COPY scripts/*.sh /
RUN chmod +x /entrypoint.sh

VOLUME [ "/var/local/data" ]
WORKDIR /var/local/data

ENV REMOTE_BRANCH master

RUN groupadd -r -g 1001 git && useradd -r -u 1001 -g git git && mkdir -p /home/git && chown git.git /home/git

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["bash", "-l", "/run.sh"]
