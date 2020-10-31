#!/bin/bash -x
## Custom MSF-OCB script for PHP app "OSTicket" for <https://helpdesk.sherlog.ocb.msf.org/> (<https://osticket.com/> with addition of <https://osticketawesome.com> plus customisations)
## Inspired from <https://hub.docker.com/r/campbellsoftwaresolutions/osticket/dockerfile>
## N.B.: Should be executed when starting the Docker container "osticket-docker", inside the container as super-user "root"!
## XKa - v2020.10.29.0

set -e

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

# Automate app installation/setup
php "$(dirname "$0")/install.php"

# Apply app configuration file security
chmod -c u=rw,go=r "${_app_www_root_dir}/include/ost-config.php"

# Enforce proper ownership of app files
chown -Rc "${_app_user_group}" "${_app_www_root_dir}"

# Block access to renamed PHP app sub-folder "setup_hidden" if it exists
_dir01="${_app_www_root_dir}/setup_hidden"
if [ -d "${_dir01}" ]; then
  chown -Rc root:root "${_dir01}"
  chmod -Rc u+r,go= "${_dir01}"
fi
unset _dir01

# Ensure daemon "cron" (used by the app) is started
service cron start

# Launch the Apache web server in foreground, as this script is replacing the original Dockerfile ENTRYPOINT
docker-php-entrypoint apache2-foreground

##EOF
