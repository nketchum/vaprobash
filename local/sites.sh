#!/usr/bin/env bash

SITES_AVAIL="/etc/nginx/sites-available"

# Normal Servers
sudo ngxcb -d /var/www/drupal.dev/web -n drupal.dev -s drupal.dev -e
sudo ngxcb -d /var/www/drupal.dev/web -n marlonow.dev -s marlonow.dev -e

# Proxy Servers
sudo nginx-generator \
  --name mailcatcher \
  --domain mail.dev \
  --type proxy \
  --var host=localhost \
  --var port=1080 \
  "${SITES_AVAIL}"/mailcatcher
sudo ngxen mailcatcher
