## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm for Laravel projects

## Git repository
The source files for this project can be found here: https://github.com/hoanguyenmanh/docker-laravel

## Pulling from Docker Hub
Pull the image from docker hub rather than downloading the git repo. This prevents you having to build the image on every docker host:

```
docker pull hoanguyenmanh/laravel
```