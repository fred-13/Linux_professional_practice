# Vagrant Dynamic Web Lab

## Task
### Deploy a stand with web applications in vagrant.
### Stand options:
```
- nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular)
- nginx + java (tomcat/jetty/netty) + go + ruby
- you can have your own combinations
```
### Optional implementations:
```
- on the host system via configs in /etc
- deploy via docker-compose
```

## Solution
### For this task I chose flask of a python web framework. I chose the next stack: Flask (Python) + uWSGI + Nginx.
### This project install a two steps. Step one runing pythonwebapp ansible role and install Flask (Python) + uWSGI. Step two install and configure Nginx web server.
### Run the command "vagarnt up" and if there are no errors then go to the following link.
### Click here: [http://mywebapp.com](http://localhost:8080/)
