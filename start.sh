#!/bin/bash

# D-Bus जनरेट और स्टार्ट करना
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# XRDP और XRDP-SESMAN को स्टार्ट करना
xrdp-sesman --pid /var/run/xrdp-sesman.pid
xrdp --nodaemon
