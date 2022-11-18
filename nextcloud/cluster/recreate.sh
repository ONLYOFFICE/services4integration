#!/usr/bin/env bash

docker compose down 

rm -rf nextcloud
rm -rf pgdata 

bash erase-logs.sh
bash run.sh

