# syntax = docker/dockerfile:1.3-labs
FROM node:current-stretch-slim
COPY . /usr/src/app

RUN <<eot bash
  mkdir -p /usr/src/app
  mkdir -p /usr/src/app/node_modules
  mkdir -p /sessions
  apt update
  apt install nano wget --no-install-recommends  -y
  apt upgrade -y
  cd /tmp
  wget -q --no-check-certificate https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  apt install ./google-chrome-stable_current_amd64.deb -y
  rm google-chrome-stable_current_amd64.deb
  apt autoremove -y
  rm -rf /var/lib/apt/lists/*
  rm -rf /usr/share/doc/*
  rm -rf /usr/share/icons/*
  cd /opt/google/chrome
  rm -rf WidevineCdm/
  cd locales
  ls | grep -v file.txt | xargs rm
  groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser
  mkdir -p /home/pptruser/Downloads
  chown -R pptruser:pptruser /home/pptruser
  chown -R pptruser:pptruser /sessions
  chown -R pptruser:pptruser /usr/src/app/node_modules
  cd /usr/src/app
  npm i @open-wa/wa-automate@latest --ignore-scripts
  chown -R pptruser:pptruser /usr/src/app
  npm cache clean --force
eot

WORKDIR /usr/src/app


# skip the puppeteer browser download
ENV PUPPETEER_SKIP_DOWNLOAD true
ENV NODE_ENV production
ENV PORT 8080

# Add your custom ENV vars here:
ENV WA_USE_CHROME true
ENV WA_POPUP true
ENV WA_DISABLE_SPINS true
ENV WA_PORT $PORT
ENV WA_EXECUTABLE_PATH /usr/bin/google-chrome-stable

EXPOSE $PORT

# test with root later
USER pptruser


ENTRYPOINT ["./start.sh", "--in-docker", "--qr-timeout", "0", "--popup", "--debug"]