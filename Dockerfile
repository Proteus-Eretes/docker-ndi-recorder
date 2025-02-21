FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Prerequisites
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt install -y --no-install-recommends avahi-daemon avahi-utils curl ca-certificates build-essential && \
    apt clean && \
    apt autoremove

# Install NDI SDK:
# 1. Download and unpack
# 2. Run install script
# 3. Copy to sdk directory
RUN curl -s https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v6_Linux.tar.gz | tar xvz -C /tmp/ && \
    yes y | bash /tmp/Install_NDI_SDK_v6_Linux.sh > /dev/null && \
    mv "NDI SDK for Linux" sdk && \
    rm /tmp/Install_NDI_SDK_v6_Linux.sh

RUN cp -P sdk/lib/x86_64-linux-gnu/* /usr/lib/ && \
    cp sdk/include/* /usr/local/include && \
    cp sdk/bin/x86_64-linux-gnu/ndi-record /usr/bin/

# Entrypoint script:
# 1. Run avahi-browse to check if mDNS will work
# 2. If not, send message and exit
# 3. Otherwise, run cmd (e.g. ndi-record [...])
RUN echo "#!/bin/bash" > entrypoint.sh && \
    echo "avahi-browse -at > /dev/null" >> entrypoint.sh && \
    echo "if [ \$? -ne 0 ]; then echo \"Couldn't connect to host avahi daemon, try running in \\\`--privileged\\\` mode\"; exit 1; fi" >> entrypoint.sh && \
    echo "echo \"Starting ndi-record for stream \$STREAM_NAME\"" >> entrypoint.sh && \
    echo "exec \"\$@\"" >> entrypoint.sh && \
    chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

CMD ndi-record -i "$STREAM_NAME" -o "$OUTPUT_FOLDER/$STREAM_NAME.mov"
