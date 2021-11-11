#!/bin/sh
# There is no bash in the container.
# In a Moodle container:
#   - the Moodle is launched;
#   - the connector is installed.

set -x

/opt/bitnami/scripts/moodle/entrypoint.sh \
'/opt/bitnami/scripts/moodle/run.sh' &> /tmp/server.log &
sleep 10
cp -r /tmp/onlyoffice /opt/bitnami/moodle/mod/onlyoffice
chown -R daemon:daemon /opt/bitnami/moodle/mod/onlyoffice/
tail -f /tmp/server.log
