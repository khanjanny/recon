#!/bin/bash

cd /usr/share/assets-from-spf  && python2 assets_from_spf.py "$@" | tr -d "+"

