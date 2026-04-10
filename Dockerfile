FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz

ENV STEAMCMD_DIR=/opt/steamcmd \
    SOULMASK_DIR=/opt/soulmask \
    SOULMASK_DATA_DIR=/data \
    SOULMASK_APP_ID=3017300 \
    SOULMASK_SERVER_NAME=Soulmask-Server \
    SOULMASK_MAX_PLAYERS=50 \
    SOULMASK_PVP=false \
    SOULMASK_LEVEL_NAME=Level01_Main \
    SOULMASK_PORT=8777 \
    SOULMASK_QUERY_PORT=27015 \
    SOULMASK_BACKUP_INTERVAL=900 \
    SOULMASK_SAVING_INTERVAL=600

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        lib32gcc-s1 \
        lib32stdc++6 \
        libcurl4 \
        tar \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /data --shell /bin/bash soulmask \
    && mkdir -p /opt/steamcmd /opt/soulmask /data \
    && chown -R soulmask:soulmask /opt/steamcmd /opt/soulmask /data

RUN curl -fsSL "${STEAMCMD_URL}" | tar -xz -C /opt/steamcmd \
    && chown -R soulmask:soulmask /opt/steamcmd

USER soulmask

RUN /opt/steamcmd/steamcmd.sh +force_install_dir /opt/soulmask +login anonymous +app_update 3017300 validate +quit

COPY --chown=soulmask:soulmask docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /opt/soulmask

EXPOSE 8777/tcp 8777/udp 27015/tcp 27015/udp 18888/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]