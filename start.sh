#!/bin/bash

if [ -z "$CHROME_CODE" ]; then
    echo "ERROR: CHROME_CODE वेरिएबल खाली है। कृपया नया कोड डालें।"
    exit 1
fi

# लाइव कोड के साथ होस्ट शुरू करना
DISPLAY= /opt/google/chrome-remote-desktop/start-host \
    --code="$CHROME_CODE" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name="Chromebook-Docker" \
    --pin="123456"

tail -f /dev/null
