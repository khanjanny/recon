#!/bin/bash

cd /usr/share/assets-from-spf  && python assets_from_spf.py "$@" | tr -d "+"

