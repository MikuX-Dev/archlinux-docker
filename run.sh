#!/usr/bin/env bash
docker rm malware-dev 2&> /dev/null
docker run -it \
  --name malware-dev