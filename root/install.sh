#! /bin/bash
set -e

# ENV
DEBIAN_FRONTEND=noninteractive
if [ -f "/dockerstartup/vnc_startup.sh" ]; then
  COPY_HOME=/home/kasm-default-profile/
  IS_KASM=true
else
  COPY_HOME=/defaults/home/
  IS_KASM=false
fi

# Directories
mkdir -p "${COPY_HOME}"Desktop

# Setup Repos
curl -s https://apt.vulns.xyz/kpcyrd.pgp | \
  gpg --dearmor -o /etc/apt/trusted.gpg.d/apt-vulns-xyz.gpg
echo "deb http://apt.vulns.xyz stable main" > /etc/apt/sources.list.d/apt-vulns-sexy.list

# Install Packages
apt-get update
apt-get install -y --no-install-recommends \
  cargo \
  chromium \
  chromium-l10n \
  drawing \
  exifprobe \
  eyewitness \
  finalrecon \
  git \
  instaloader \
  joplin \
  keepassxc \
  maltego \
  metagoofil \
  osrframework \
  outguess \
  photon \
  pipx \
  pkg-config \
  python3-fake-useragent \
  rsync \
  sherlock \
  sn0int \
  stegosuite \
  sublist3r \
  webhttrack \
  yt-dlp \
  xz-utils

# Install Tor
TOR_URL=$(curl -q https://www.torproject.org/download/ | \
          grep downloadLink | \
          grep linux | \
          sed 's/.*href="//g' | \
          cut -d '"' -f1 | head -1)
curl -o \
  /tmp/torbrowser.tar.xz -L \
  "https://www.torproject.org/${TOR_URL}"
tar -xJf \
  /tmp/torbrowser.tar.xz -C \
  "${COPY_HOME}"
sed -i \
  -e "/^Exec=/c Exec=/bin/sh -c \"\$HOME\/tor-browser\/Browser\/start-tor-browser --detach %U\"" \
  -e 's:^Icon=.*:Icon=torbrowser:g' \
  -e 's/Name=Tor Browser Setup/Name=Tor Browser/g' \
  "${COPY_HOME}"tor-browser/start-tor-browser.desktop
cp \
  "${COPY_HOME}"tor-browser/Browser/browser/chrome/icons/default/default128.png \
  /usr/share/icons/hicolor/128x128/apps/torbrowser.png
cp \
  "${COPY_HOME}"tor-browser/start-tor-browser.desktop \
  /usr/share/applications/
chmod 644 \
  /usr/share/applications/start-tor-browser.desktop \
  /usr/share/icons/hicolor/128x128/apps/torbrowser.png

# Install Obsidian
OBSIDIAN_VERSION=$(curl -sX GET "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest"| awk '/tag_name/{print $4;exit}' FS='[""]'); \
cd /tmp
curl -o \
  /tmp/obsidian.app -L \
  "https://github.com/obsidianmd/obsidian-releases/releases/download/${OBSIDIAN_VERSION}/Obsidian-$(echo ${OBSIDIAN_VERSION} | sed 's/v//g').AppImage"
chmod +x /tmp/obsidian.app
./obsidian.app --appimage-extract
mv squashfs-root /opt/obsidian
cp \
  /opt/obsidian/usr/share/icons/hicolor/512x512/apps/obsidian.png \
  /usr/share/icons/hicolor/512x512/apps/obsidian.png
chown -R 1000:1000 /opt/obsidian/
cat >/usr/share/applications/obsidian.desktop <<EOL
[Desktop Entry]
Name=Obsidian
Exec=/opt/obsidian/AppRun %U
Terminal=false
Type=Application
Icon=obsidian
StartupWMClass=obsidian
Comment=Obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;
EOL
cp \
  /usr/share/applications/obsidian.desktop \
  "${COPY_HOME}"Desktop/
chmod +x "${COPY_HOME}"Desktop/obsidian.desktop

# Install python deps
pipx install \
  h8mail \
  toutatis \
  youtube-dl
pip3 install \
  dnsdumpster \
  onionsearch \
  tweepy

# Install phoneinfoga  
curl -sL \
  https://raw.githubusercontent.com/sundowndev/phoneinfoga/master/support/scripts/install \
  | bash

# Modify apps to use sudo for root
sed -i \
  's/Exec=pkexec/Exec=sudo/g' \
  /usr/share/applications/*

# Copy over files from vm repo
TL_RELEASE=$(curl -sX GET "https://api.github.com/repos/tracelabs/tlosint-vm/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]')
git clone https://github.com/tracelabs/tlosint-vm.git
cd tlosint-vm
git checkout -f "${TL_RELEASE}"
if [ "${IS_KASM}" != "true" ]; then
  rm -Rf overlays/tl-overlays/etc/xdg
fi
rsync -aviu overlays/tl-overlays/etc/ /etc/
rm -Rf /etc/skel
rsync -aviu overlays/tl-overlays/usr/ /usr/
cat >"${COPY_HOME}"Desktop/tofm.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Trace Labs OSINT Field Manual
Type=Link
URL=https://github.com/tracelabs/tofm/blob/main/tofm.md
Icon=tracelabs
EOL
cp -ax \
  overlays/tl-overlays/etc/skel/Desktop/*.pdf \
  overlays/tl-overlays/etc/skel/Desktop/TL-Vault \
  "${COPY_HOME}"Desktop/
git clone \
  https://github.com/tjnull/TJ-OSINT-Notebook.git \
  "${COPY_HOME}"Desktop/TJ-OSINT-Notebook

# Icon cache
update-icon-caches /usr/share/icons/*
