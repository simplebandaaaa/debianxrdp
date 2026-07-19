FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Multi-arch support block for Wine32
RUN dpkg --add-architecture i386

# Firefox के लिए Mozilla PPA जोड़ना (Snap से बचने के लिए)
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common gnupg2 && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox

# Update and install packages (ChromeOS थीम्स के लिए git और unzip जोड़ा गया है)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xrdp \
    xorgxrdp \
    xfce4 \
    xfce4-goodies \
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
    pulseaudio \
    pulseaudio-utils \
    wine64 \
    wine32:i386 \
    firefox \
    git \
    unzip \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ---- 📂 CHROMEOS THEME & ICONS INSTALLATION ---- #
# ChromeOS Light Theme और Icon Pack डाउनलोड और इंस्टॉल करना
RUN mkdir -p /usr/share/themes /usr/share/icons && \
    # ChromeOS GTK Theme
    git clone https://github.com/vinceliuice/Chrome-OS-themes.git /tmp/chrome-theme && \
    /tmp/chrome-theme/install.sh -d /usr/share/themes && \
    # ChromeOS Icon Theme (Tela or Cupertino style)
    git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icons && \
    /tmp/tela-icons/install.sh -d /usr/share/icons && \
    rm -rf /tmp/chrome-theme /tmp/tela-icons
# ------------------------------------------------ #

# ---- 🛠️ USER SETUP FIX ---- #
RUN echo "ubuntu:ubuntu" | chpasswd && \
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

# ---- 🖥️ CHROMEOS LOOK DEFAULT SETTINGS ---- #
# XFCE को यह बताने के लिए कि वो डिफ़ॉल्ट रूप से ChromeOS थीम और आइकॉन्स का इस्तेमाल करे
RUN mkdir -p /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml && \
    chown -R ubuntu:ubuntu /home/ubuntu/.config

# थीम और आइकॉन सेट करने के लिए XML कॉन्फ़िगरेशन फ़ाइल बनाना
RUN printf '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="ChromeOS-Light"/>\n\
    <property name="IconThemeName" type="string" value="Tela"/>\n\
  </property>\n\
</channel>\n' > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# XFCE Environment Startup Fix
RUN printf 'unset DBUS_SESSION_BUS_ADDRESS\nunset XDG_RUNTIME_DIR\nexport XDG_SESSION_TYPE=x11\nexec dbus-launch --exit-with-session xfce4-session\n' > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession

# Add xrdp user to ssl-cert group
RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
