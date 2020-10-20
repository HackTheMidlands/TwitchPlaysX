# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-18.04-v3

# Install xterm.
RUN add-pkg xterm xdotool nodejs

# Copy the start script.
COPY startapp.sh /startapp.sh

# Set the name of the application.
ENV APP_NAME="Xterm"

COPY root/ /

RUN mkdir -p /opt/TwitchPlaysX

WORKDIR /opt/TwitchPlaysX

COPY package.json package-lock.json ./

RUN npm install

COPY . ./
