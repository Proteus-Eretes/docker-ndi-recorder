FROM debian:bullseye

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Prerequisites
RUN --mount=target=/var/lib/apt,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt install -y --no-install-recommends avahi-daemon avahi-utils curl ca-certificates && \
    apt clean && \
    apt autoremove

# Install NDI SDK:
# 1. Download and unpack
# 2. Run install script
# 3. Copy to sdk directory
RUN curl -s https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz | tar xvz -C /tmp/ && \
    yes y | bash /tmp/Install_NDI_SDK_v5_Linux.sh > /dev/null && \
    mv "NDI SDK for Linux" sdk

RUN cp sdk/lib/x86_64-linux-gnu/* /usr/lib/
RUN cp sdk/bin/x86_64-linux-gnu/ndi-record /usr/bin/

CMD ndi-record -i "$STREAM_NAME" -o "$OUTPUT_FOLDER/$STREAM_NAME.mov"
