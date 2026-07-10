FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Multi-arch support block for Wine32
RUN dpkg --add-architecture i386

# Firefox के लिए Mozilla PPA जोड़ना (Snap से बचने के लिए - printf का उपयोग किया गया है ताकि एरर न आए)
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common gnupg2 && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox

# Update and install packages (Wine और Wine32 की समस्या को भी फिक्स कर दिया गया है)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    ssl-cert \
    polkitd \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32:i386 \
    firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 🛠️ USER SETUP FIX ---- #
# एक नया यूजर 'ubuntu' बनाएं और उसका पासवर्ड 'ubuntu' सेट करें
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# ---------------------------- #

# Configure Xwrapper
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# Optimize XRDP Configuration
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=24/' /etc/xrdp/xrdp.ini

# Ensure XFCE starts safely for the new user (Fixes black screen)
RUN echo "unset DBUS_SESSION_BUS_ADDRESS" > /etc/skel/.xsession && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/skel/.xsession && \
    echo "exec startxfce4" >> /etc/skel/.xsession && \
    cp /etc/skel/.xsession /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# Add xrdp user to ssl-cert group
RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
