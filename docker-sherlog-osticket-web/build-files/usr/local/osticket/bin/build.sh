#!/bin/bash
## Custom MSF-OCB script for PHP app "OSTicket" for <https://helpdesk.sherlog.ocb.msf.org/> (<https://osticket.com/> with addition of <https://osticketawesome.com> plus customisations)
## Inspired from <https://hub.docker.com/r/campbellsoftwaresolutions/osticket/dockerfile>, <https://github.com/CampbellSoftwareSolutions/docker-osticket>
## N.B.: Should be executed when building the Docker container "osticket-docker" (based on official Docker hub image "php:7-apache", using "Debian GNU/Linux 10 (buster)"), inside the container as super-user "root"!
## Ref.: <https://docs.docker.com/develop/develop-images/dockerfile_best-practices/>
## XKa - v2021.01.21.0

set -ex

# Generate basic debug info
: "$(date +'%F_%T%z')"
: "$(uname -a)"
: "\"$(whoami)\"@\"$(hostname)\":\"$(pwd)\""
: "\"$(realpath "${BASH_SOURCE[0]:-${0}}")\""
: "\"${0}\" $*"
:
declare -p

_php_config_dir="/usr/local/etc/php"
_app_www_root_dir="/var/www/html"
_app_user_group="www-data:www-data"


_pear_orig_temp_dir="$(pear config-get temp_dir)"
_temp_exec_dir="/root/tmp"

_dir01="${_temp_exec_dir}"
if [ ! -d "${_dir01}" ]; then
  mkdir -pv "${_dir01}"
fi
unset _dir01

# Create PHP log folder if not exists and (re)set its ownership
_dir01="/var/log/php"
if [ ! -d "${_dir01}" ]; then
  mkdir -pv "${_dir01}"
fi
chown -Rc "${_app_user_group}" "${_dir01}"
unset _dir01

# Create MSMTP log file if not exists and (re)set its ownership
_file01="/var/log/msmtp.log"
if [ ! -e "${_file01}" ]; then
  : >> "${_file01}"
fi
chown -c "${_app_user_group}" "${_file01}"
unset _file01

# Copy PHP ini file (production or development)
cp -fpv "${_php_config_dir}/php.ini-production" "${_php_config_dir}/php.ini"


# Install packages for app setup and for PHP extensions
apt-get update
apt-get install -y cron wget msmtp zlib1g-dev libpng-dev libcurl4-openssl-dev libldap2-dev libonig-dev libxml2-dev libc-client-dev libkrb5-dev libzip-dev
rm -rf /var/lib/apt/lists/*

# Enable Apache httpd 'mod_rewrite'
a2enmod rewrite

# Install PHP extensions
docker-php-ext-install gd ldap mysqli sockets gettext intl opcache zip
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
docker-php-ext-install imap
# (see e.g. <https://stackoverflow.com/questions/34170434/how-install-apcu-as-php7-extension-on-debian> , <https://stackoverflow.com/questions/8141407/install-pecl-modules-without-the-prompts>)
pear config-set temp_dir /root/tmp
pecl channel-update pecl.php.net
pecl install apcu < /dev/null
docker-php-ext-enable apcu
pear config-set temp_dir "${_pear_orig_temp_dir}"


# Exit with success code
exit 0

##EOF
