#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
HHVM=$2
PHP_VERSION=$3
PHP_PATH=$4
PHP_CMD=$5

if [[ $HHVM == "true" ]]; then

    echo ">>> Installing HHVM"

    # Get key and add to sources
    wget --quiet -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
    echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list

    # Update
    sudo apt-get update

    # Install HHVM
    # -qq implies -y --force-yes
    sudo apt-get install -qq hhvm

    # Start on system boot
    sudo update-rc.d hhvm defaults

    # Replace PHP with HHVM via symlinking
    sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

    sudo service hhvm restart
else
    echo ">>> Installing PHP $PHP_VERSION"

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

    if [ $PHP_VERSION == "5.5" ]; then
        # Add repo for PHP 5.5
        sudo add-apt-repository -y ppa:ondrej/php5
    elif [ $PHP_VERSION == '5.6' ]; then
        # Add repo for PHP 5.6
        sudo add-apt-repository -y ppa:ondrej/php5-5.6
    elif [ $PHP_VERSION == '7.0' ]; then
        # Fix any broken add-apt-repository locales
        sudo apt-get install -y language-pack-en-base
        # Add repo for PHP 7.0
        sudo LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
    fi

    sudo apt-key update
    sudo apt-get update

    # Install PHP
    # -qq implies -y --force-yes
    if [ $PHP_VERSION == "7.0" ]; then
        # xdebug not supported yet
        sudo apt-get install -qq php7.0-cli php7.0-fpm php7.0-dev php-pear php-imagick php-memcached php7.0-curl php7.0-gd php7.0-gmp php7.0-imap php7.0-intl php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-pgsql php7.0-sqlite php7.0-xml
    else
        sudo apt-get install -qq php5-cli php5-fpm php5-dev php-pear php5-cgi php5-common php5-curl php5-gd php5-gmp php5-imagick php5-imap php5-intl php5-json php5-ldap php5-mbstring php5-mcrypt php5-memcached php5-mysql php5-pgsql php5-sqlite
    fi

    # Set PHP FPM to listen on TCP instead of Socket
    sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" "$PHP_PATH"/fpm/pool.d/www.conf

    # Set PHP FPM allowed clients IP address
    sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" "$PHP_PATH"/fpm/pool.d/www.conf

    # Set run-as user for PHP5-FPM processes to user/group "vagrant"
    # to avoid permission errors from apps writing to files
    sudo sed -i "s/user = www-data/user = vagrant/" "$PHP_PATH"/fpm/pool.d/www.conf
    sudo sed -i "s/group = www-data/group = vagrant/" "$PHP_PATH"/fpm/pool.d/www.conf

    sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" "$PHP_PATH"/fpm/pool.d/www.conf
    sudo sed -i "s/listen\.group.*/listen.group = vagrant/" "$PHP_PATH"/fpm/pool.d/www.conf
    sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" "$PHP_PATH"/fpm/pool.d/www.conf


    if [ $PHP_VERSION == "5.5" ] || [ $PHP_VERSION == "5.6" ]; then
        # xdebug Config (not yet supported in PHP7)
        cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOF
    fi

    # PHP Error Reporting Config
    sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" "$PHP_PATH"/fpm/php.ini
    sudo sed -i "s/display_errors = .*/display_errors = On/" "$PHP_PATH"/fpm/php.ini

    # PHP Date Timezone
    sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" "$PHP_PATH"/fpm/php.ini
    sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" "$PHP_PATH"/cli/php.ini

    sudo service $PHP_CMD restart

fi
