FROM linuxserver/kali-linux:latest

# title
ENV TITLE="Trace Labs" \
    LSIO_FIRST_PARTY=false

# Cleanup default wallpapers
RUN \
 rm -Rf \
  /usr/share/wallpapers/Next/contents/images_dark/*

# add local files
COPY /root /

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://kasm-ci.s3.amazonaws.com/tracelabs.png && \
  echo "**** run install logic ****" && \
  bash /install.sh && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
