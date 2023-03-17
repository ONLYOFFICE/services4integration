#!/bin/sh
set -x

echo "ENABLE_ONLYOFFICE = True
VERIFY_ONLYOFFICE_CERTIFICATE = False
ONLYOFFICE_APIJS_URL = 'http://${SEAFILE_SERVER_HOSTNAME}:3000/web-apps/apps/api/documents/api.js'
ONLYOFFICE_FILE_EXTENSION = ('doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt', 'fodt', 'odp', 'fodp', 'ods', 'fods')
ONLYOFFICE_EDIT_FILE_EXTENSION = ('docx', 'pptx', 'xlsx')
ONLYOFFICE_FORCE_SAVE = True
ONLYOFFICE_JWT_SECRET = '${ONLYOFFICE_JWT_SECRET}'" >> /opt/seafile/conf/seahub_settings.py
