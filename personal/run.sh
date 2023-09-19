#!/usr/bin/env bash
docker rm dev-env 2&> /dev/null
docker run -it \
  --name dev-env