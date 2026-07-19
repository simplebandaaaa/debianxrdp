#!/bin/bash

# आपके कोड के साथ Google Remote Desktop होस्ट को शुरू करना
DISPLAY= /opt/google/chrome-remote-desktop/start-host \
    --code="4/0AXEQxIDTgqQK7ct5ctOfi77pDUCTmTnvmDFru4l4NY-0t__CP40j0Ysr_cQ4BXV6kyn0EQ" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name="Chromebook-Docker" \
    --pin="123456"

# कंटेनर को चालू रखने के लिए
tail -f /dev/null
