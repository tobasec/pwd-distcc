#!/usr/bin/env bash
set -e

mkdir /tmp/distcc

mount -t tmpfs -o size=5G tmpfs /tmp/distcc

chmod +x /root/*

make build

make run