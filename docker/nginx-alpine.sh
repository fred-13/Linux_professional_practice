#!/bin/bash

cd nginx-alpine
docker build -t fred13/nginx-alpine:latest .
docker run -d -p 8181:80 fred13/nginx-alpine:latest
cd -
