FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# आवश्यक टूल्स और XFCE डेस्कटॉप इंस्टॉल करना
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    curl \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    xfce4 \
    xfce4-goodies \
    xserver-xorg-video-dummy \
    desktop-base \
    lightdm \
    dbus-x11 \
    python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Chrome Remote Desktop इंस्टॉल करना
RUN wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    apt-get update && apt-get install -y --no-install-recommends ./chrome-remote-desktop_current_amd64.deb && \
    rm chrome-remote-desktop_current_amd64.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Google Chrome Browser इंस्टॉल करना
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Chromebook User (chronos) सेटअप
RUN useradd -m -s /bin/bash -G sudo chronos && \
    echo "chronos:chronos" | chpasswd && \
    echo "chronos ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Chrome Remote Desktop को XFCE4 इस्तेमाल करने के लिए कॉन्फ़िगर करना
RUN echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session

USER chronos
WORKDIR /home/chronos

RUN mkdir -p .config/chrome-remote-desktop

COPY --chown=chronos:chronos start.sh /home/chronos/start.sh
RUN chmod +x /home/chronos/start.sh

CMD ["/home/chronos/start.sh"]
