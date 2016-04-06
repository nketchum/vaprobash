#!/usr/bin/env bash

echo ">>> Installing Couchbase Server"

# Get php version arg
PHP_CMD=$1
PHP_ENMOD=$2

# Set some variables
COUCHBASE_EDITION=community
COUCHBASE_VERSION=2.2.0 # Check http://http://www.couchbase.com/download/ for latest version
COUCHBASE_ARCH=x86_64


wget --quiet http://packages.couchbase.com/releases/${COUCHBASE_VERSION}/couchbase-server-${COUCHBASE_EDITION}_${COUCHBASE_VERSION}_${COUCHBASE_ARCH}.deb
sudo dpkg -i couchbase-server-${COUCHBASE_EDITION}_${COUCHBASE_VERSION}_${COUCHBASE_ARCH}.deb
rm couchbase-server-${COUCHBASE_EDITION}_${COUCHBASE_VERSION}_${COUCHBASE_ARCH}.deb

php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ ${PHP_IS_INSTALLED} -eq 0 ]; then
    sudo wget --quiet -O/etc/apt/sources.list.d/couchbase.list http://packages.couchbase.com/ubuntu/couchbase-ubuntu1204.list
    wget --quiet -O- http://packages.couchbase.com/ubuntu/couchbase.key | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -qq install libcouchbase2-libevent libcouchbase-dev

    sudo pecl install couchbase-1.2.2
    sudo cat > /etc/php5/mods-available/couchbase.ini << EOF
; configuration for php couchbase module
; priority=30
extension=couchbase.so
EOF
    sudo $PHP_ENMOD couchbase
    sudo service $PHP_CMD restart
fi