# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-18.04-v3

ENV VERSION 2.1.4
ENV SHA1HASH bf6e452b53f47e2fbc4e6e41c92f567aa285cdbe

# Install xterm.
RUN add-pkg xterm xdotool nodejs

RUN apt update \
  && apt -qq -y --no-install-recommends install \
  ca-certificates \
  tar \
  wget \
  # -- from builddeps script
  build-essential \
  g++ \
  nasm \
  cmake \
  ccache \
  gettext \
  zlib1g-dev \
  libgl1-mesa-dev \
  libavcodec-dev \
  libavformat-dev \
  libswscale-dev \
  libavutil-dev \
  libswresample-dev \
  libgettextpo-dev \
  libpng-dev \
  libsdl2-dev \
  libsdl2-2.0 \
  libglu1-mesa-dev \
  libglu1-mesa \
  libgles2-mesa-dev \
  libsfml-dev \
  libsfml-graphics2.4 \
  libsfml-network2.4 \
  libsfml-window2.4 \
  libglew2.0 \
  libopenal-dev \
  libwxgtk3.0-dev \
  libwxgtk3.0 \
  libgtk2.0-dev \
  libgtk-3-dev \
  zip \
  # sound driver to play sound on host
  pulseaudio \
  # su command
  gosu \
  # build
  && mkdir /vbam-build && cd /vbam-build \
  && wget -O vbam.tar.gz https://github.com/visualboyadvance-m/visualboyadvance-m/archive/v${VERSION}.tar.gz \
  && echo "${SHA1HASH} vbam.tar.gz" | sha1sum -c - \
  && mkdir src \
  && tar xf vbam.tar.gz -C src --strip-components 1 \
  && mkdir build && cd build \
  && cmake ../src \
  && make -j$(nproc) \
  # copy to /usr/local/bin/
  && mv visualboyadvance-m /usr/local/bin/ \
  # remove build environment
  && rm -r /vbam-build/


# Copy the start script.
COPY startapp.sh /startapp.sh

# Set the name of the application.
ENV APP_NAME="HTM Plays!"

COPY root/ /

RUN mkdir -p /opt/TwitchPlaysX

WORKDIR /opt/TwitchPlaysX

COPY package.json package-lock.json ./

RUN npm install

COPY . ./

RUN useradd -m bot

