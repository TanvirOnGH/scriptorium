#!/bin/sh

systemd-machine-id-setup
systemd-firstboot --prompt
systemctl preset-all
