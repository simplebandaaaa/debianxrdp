FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Multi-arch support block for Wine32
RUN dpkg --add-architecture i386

# Firefox के लिए Mozilla PPA जोड़ना (Snap से बचने के लिए)
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common gnupg2 && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox

# Update and install packages (GNOME और XRDP के लिए)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    ubuntu-desktop-minimal \
    gnome-session \
    gnome-terminal \
    xorg \
    dbus-x11 \
    dbus-user-session \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    ssl-cert \
    polkitd \
    wine \
    wine32:i386 \
    firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 🛠️ USER SETUP FIX ---- #
RUN mkdir -p /home/ubuntu && \
    usermod -d /home/ubuntu -m ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# ---------------------------- #

# Configure Xwrapper
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=no" >> /etc/X11/Xwrapper.config

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# Optimize XRDP Configuration
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=24/' /etc/xrdp/xrdp.ini

# ---- 🛠️ GNOME RDP FIX (ब्लैक स्क्रीन से बचने के लिए सबसे जरूरी हिस्सा) ---- #
# GNOME को चलाने के लिए XDG environment variables सेट करना जरूरी है
RUN printf 'export XDG_CURRENT_DESKTOP=GNOME\nexport XDG_SESSION_TYPE=x11\nexport XDG_SESSION_DESKTOP=ubuntu\nexec gnome-session\n' > /home/ubuntu/.xsession && \
    printf 'export XDG_CURRENT_DESKTOP=GNOME\nexport XDG_SESSION_TYPE=x11\nexport XDG_SESSION_DESKTOP=ubuntu\n' > /home/ubuntu/.xsessionrc && \
    chown -R ubuntu:ubuntu /home/ubuntu

# Add xrdp user to ssl-cert group
RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
