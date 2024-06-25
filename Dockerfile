FROM ubuntu:22.04

ARG GSTD_BRANCH=v0.15.0
ARG INTERPIPE_BRANCH=v1.1.8

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    sudo \
    git \
    tzdata \
    dumb-init \
    curl \
    iputils-ping \
    automake \
    libtool \
    pkg-config \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libglib2.0-dev \
    libjson-glib-dev \
    gtk-doc-tools \
    libreadline-dev \
    libncursesw5-dev \
    libdaemon-dev \
    libjansson-dev \
    libsoup2.4-dev \
    libedit-dev \
    python3-pip \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-vaapi

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Install GSTD
RUN git clone --depth 1 --branch $GSTD_BRANCH https://github.com/RidgeRun/gstd-1.x.git
RUN cd gstd-1.x && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install
RUN rm -rf /app/gstd-1.x

## Install Plugin interpipes
RUN git clone --depth 1 --branch $INTERPIPE_BRANCH https://github.com/RidgeRun/gst-interpipe.git
RUN cd /app/gst-interpipe && \
    ./autogen.sh --libdir /usr/lib/x86_64-linux-gnu/ && \
    make && \
    make install
RUN rm -rf /app/gst-interpipe
RUN gst-inspect-1.0 interpipe

RUN mkdir -p /app/recording

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["bash", "-c", "/usr/local/bin/gstd \
    --enable-http-protocol \
    --http-address=0.0.0.0 \
    --http-port=8080"]