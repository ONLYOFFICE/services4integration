#!/bin/sh
# There is no bash in the container.
# In a Moodle container:
#   - the Moodle is launched;
#   - the connector is installed.

set -x

/opt/bitnami/scripts/moodle/entrypoint.sh \
'/opt/bitnami/scripts/moodle/run.sh' &> /tmp/server.log &
sleep 10
cp -r /tmp/onlyoffice/docspace /opt/bitnami/moodle/mod/onlyofficedocspace
chown -R daemon:daemon /opt/bitnami/moodle/mod/onlyofficedocspace/
cp -r /tmp/onlyoffice/docs /opt/bitnami/moodle/mod/onlyofficeeditor
chown -R daemon:daemon /opt/bitnami/moodle/mod/onlyofficeeditor/
tail -f /tmp/server.log
