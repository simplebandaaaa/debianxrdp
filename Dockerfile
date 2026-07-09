FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Multi-arch support block for Wine32
RUN dpkg --add-architecture i386

# Update and install packages in a single optimized layer
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
    wine32 \
    firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:root" | chpasswd

# Configure Xwrapper to allow any user to start X
RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

# Optimize XRDP Configuration (Safely without wiping out startwm.sh)
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    sed -i 's/max_bpp=32/max_bpp=24/' /etc/xrdp/xrdp.ini

# Ensure XFCE starts for any RDP user session safely (Fixes black screen bug)
RUN echo "unset DBUS_SESSION_BUS_ADDRESS" > /etc/skel/.xsession && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/skel/.xsession && \
    echo "exec startxfce4" >> /etc/skel/.xsession && \
    cp /etc/skel/.xsession /root/.xsession

# Add xrdp user to ssl-cert group
RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
