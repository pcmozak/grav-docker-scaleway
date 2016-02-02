# build for arm
FROM armbuild/phusion-baseimage 
# build for x64
#FROM phusion/baseimage:0.9.15

MAINTAINER pcmozak <admin@pcmozak.com>

CMD ["/sbin/my_init"]


ENV GRAV_VERSION 1.0.8
ENV HOME /root
ENV HTML_ROOT_DIR /usr/share/nginx/html
ENV DEBIAN_FRONTEND noninteractive

#Install core packages
RUN apt-get update -q \
 && apt-get upgrade -y -q && apt-get install -y -q php5 \
						   php5-cli \
						   php5-fpm \
                                                   php5-gd \
						   php5-curl \
						   php5-apcu \
						   ca-certificates \
						   nginx \
						   git \
						   zip \
						   rsync \
			  && apt-get clean -q \
			  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#Get Grav
WORKDIR ${HTML_ROOT_DIR}
RUN rm -rf ${HTML_ROOT_DIR}/* \
	&& curl -o grav.zip -SL https://github.com/getgrav/grav/releases/download/${GRAV_VERSION}/grav-admin-v${GRAV_VERSION}.zip \
	&& unzip grav.zip -d /tmp \
	&& rsync -rtv /tmp/grav-admin/ ${HTML_ROOT_DIR}/ \
	#Just for the lulz. This will fail if something is wrong with php
	&& bin/gpm install admin \
	&& chown -R www-data:www-data /usr/share/nginx/html

#Configure Nginx - enable gzip
RUN sed -i 's|# gzip_types|  gzip_types|' /etc/nginx/nginx.conf \
#Setup Grav configuration for Nginx
    && mv ${HTML_ROOT_DIR}/webserver-configs/nginx.conf /etc/nginx/sites-available/default \
    && sed -i \
        -e 's|root /home/user/www/html|root /usr/share/nginx/html|' \
        /etc/nginx/sites-available/default \
#Setup Php service
    && mkdir -p /etc/service/php5-fpm \
    && touch /etc/service/php5-fpm/run \
    && chmod +x /etc/service/php5-fpm/run \
    && echo '#!/bin/bash \n\
            exec /usr/sbin/php5-fpm -F' >> /etc/service/php5-fpm/run \
#Setup Nginx service
    && mkdir -p /etc/service/nginx \
    && touch /etc/service/nginx/run \
    && chmod +x /etc/service/nginx/run \
    && echo '#!/bin/bash \n\
    	    exec /usr/sbin/nginx -g "daemon off;"' >>  /etc/service/nginx/run

#Expose configuration and content volumes
VOLUME ["/root/.ssh", "/usr/share/nginx/html"]

#Public ports
EXPOSE 80 25
