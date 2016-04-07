#!/usr/bin/env bash

SITES_AVAIL="/etc/nginx/sites-available"

# Normal Servers

sudo ngxcb -d /var/www/swedgen/src -n swedgen.dev -s swedgen.dev -e
sudo ngxcb -d /var/www/swidgen -n swidgen.dev -s swidgen.dev -e

# Proxy Servers

sudo nginx-generator \
  --name mailcatcher \
  --domain mail.dev \
  --type proxy \
  --var host=localhost \
  --var port=1080 \
  "${SITES_AVAIL}"/mailcatcher
sudo ngxen mailcatcher

sudo nginx-generator \
  --name nodeauth.dev \
  --domain nodeauth.dev \
  --type proxy \
  --var host=localhost \
  --var port=3031 \
  "${SITES_AVAIL}"/nodeauth.dev
sudo ngxen nodeauth.dev
cd /var/www/nodeauth
npm start
cd -
