FROM debian:12

ENV TZ=Asia/Singapore

USER root

ARG USERNAME=distcc
ARG USER_GROUP=$USERNAME

ENV HOME=/home/$USERNAME

RUN export DEBIAN_FRONTEND=noninteractive && \
    groupadd --system $USERNAME && \
    useradd --system --shell /bin/bash --no-log-init --home-dir $HOME --gid $USER_GROUP $USERNAME && \
    apt update && apt install -y \
        build-essential \
        clang \
        zlib1g-dev \
        ccache \
        curl \
        distcc \
        tzdata \
        ntpdate \
        htop \
        net-tools \
    && curl -L --retry 10 --silent --show-error --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$(dpkg --print-architecture).deb && \
    dpkg -i cloudflared.deb > /dev/null 2>&1 && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure tzdata

COPY limits.conf /etc/security/
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

# We check the health of the container by checking if the statistics
# are served. (See
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1

