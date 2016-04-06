#!/usr/bin/env bash

echo ">>> Installing PHP MSSQL"

# Get PHP version
PHP_VERSION=$1

# Test if PHP is installed
php -v > /dev/null 2>&1 || { printf "!!! PHP is not installed.\n    Installing PHP MSSQL aborted!\n"; exit 0; }

sudo apt-get update

# Install MSSQL if PHP != 7.0
if [ $PHP_VERSION == "7.0" ]; then
  echo ">>> ERROR: PHP7 does not support MS SQL Server. Aborting script."
  exit 1
fi
# -qq implies -y --force-yes
sudo apt-get install -qq php5-mssql

echo ">>> Installing freeTDS for MSSQL"

# Install freetds
sudo apt-get install -qq freetds-dev freetds-bin tdsodbc

echo ">>> Installing UnixODBC for MSSQL"

# Install unixodbc
sudo apt-get install -qq unixodbc unixodbc-dev

# Restart php5-fpm
sudo service php5-fpm restart