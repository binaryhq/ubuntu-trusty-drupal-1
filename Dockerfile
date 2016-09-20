FROM ubuntu:trusty
MAINTAINER nignappa <ningappa@poweruphosting.com>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD wordpress.sql /wordpress.sql


RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
#RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
#RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
#ADD https://wordpress.org/latest.tar.gz /var/www/latest.tar.gz
#RUN cd /var/www/ && tar xvf latest.tar.gz && rm latest.tar.gz
#RUN cp -rf  /var/www/wordpress/* /var/www/html/
#RUN rm -rf /var/www/wordpress
#ADD wp-config.php /var/www/html/wp-config.php
#RUN rm /var/www/html/index.html
#RUN chown -R www-data:www-data /var/www/

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drupal Console.
RUN curl https://drupalconsole.com/installer -L -o drupal.phar
RUN mv drupal.phar /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal
RUN drupal init --override


# Install Drupal.
RUN rm -rf /var/www/html
RUN cd /var/www && \
	drupal site:new html 8.1.8
RUN mkdir -p /var/www/html/sites/default/files && \
	chmod a+w /var/www/html/sites/default -R && \
	mkdir /var/www/html/sites/all/modules/contrib -p && \
	mkdir /var/www/html/sites/all/modules/custom && \
	mkdir /var/www/html/sites/all/themes/contrib -p && \
	mkdir /var/www/html/sites/all/themes/custom && \
	cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php && \
	cp /var/www/html/sites/default/default.services.yml /var/www/html/sites/default/services.yml && \
	chmod 0664 /var/www/html/sites/default/settings.php && \
	chmod 0664 /var/www/html/sites/default/services.yml && \
	chown -R www-data:www-data /var/www/html/


#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
