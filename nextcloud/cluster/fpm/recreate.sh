#!/usr/bin/env bash

docker compose down 

rm -rf nextcloud
rm -rf pgdata 
rm -rf logs

bash run.sh

