#!/bin/bash
service dbus start
service xrdp start
exec xrdp-sesman --nodaemon
