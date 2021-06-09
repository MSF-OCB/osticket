## Custom MSF-OCB configuration file "Dockerfile" for PHP app "OSTicket" for <https://helpdesk.sherlog.ocb.msf.org/> (<https://osticket.com/> with addition of <https://osticketawesome.com> plus customisations)
## Inspired from <https://hub.docker.com/r/campbellsoftwaresolutions/osticket/dockerfile> but using Apache HTTPD instead of NGINX, as the latter is not officially supported by OSTicket (problems encountered)!
## XKa - v2021.06.09.1
## Ref.: <https://docs.docker.com/develop/develop-images/dockerfile_best-practices/>

FROM php:7-apache

# Environment for PHP app
ENV HOME=/var/www/html

# Set workdir for PHP app
WORKDIR ${HOME}

# Inject external files for PHP app
COPY ./build-files /

# Set up PHP app while building image
RUN ["/bin/bash", "-x", "/usr/local/osticket/bin/build.sh"]

# Set up PHP app while starting container
ENTRYPOINT ["/bin/bash", "-x", "/usr/local/osticket/bin/start.sh"]

##EOF
