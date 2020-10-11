## Task 1: Create your custom nginx image based on alpine. After starting nginx should give a custom page (just change the default nginx page).
## The Vagrunt up command will first prepare a script to create a custom image and launch a container with that image:
```
docker build -t fred13/nginx-alpine:latest .
docker run -d -p 8181:80 fred13/nginx-alpine:latest
```
## Web will be available at this link: [http://nginx-alpine](http://localhost:8181)
## For push this image on dockerhub needed use this commands:
```
docker login
docker push fred13/nginx-alpine:latest
```
## Link for image fred13/nginx-alpine:latest on dockerhub: [https://fred13/nginx-alpine](https://hub.docker.com/repository/docker/fred13/nginx-alpine/)

## Task 2: Create custom nginx and php images, merge them into docker-compose.
## Second provison script run project with this images:
```
docker-compose up -d
```
## Web will be available at this link: [http://nginx-php](http://localhost:8282)

## Questions: 1. Determine the difference between container and image. 2. Is it possible to build a kernel in a container?
## The answers: 1 - an image is analogous to a virtual machine image. A container is a running (or stopped) instance of this image. 2 - Docker containers can't load kernel modules. You need a virtual machine with an isolated kernel for that.
