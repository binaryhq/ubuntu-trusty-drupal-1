#!/bin/bash

cd /var/www/html && \
drupal site:install standard \
	--langcode en \
	--site-name="Drupal 8" \
	--db-type='mysql' \
	--db-host="localhost" \
	--db-port=3306 \
	--db-user=${MYSQL_USER:-'admin'} \
	--db-pass=${MYSQL_PASS:-'admin'} \
	--db-name=${MYSQL_DBNAME:-'admin'} \
	--db-prefix="drupal_" \
	--site-mail=${USER_EMAIL:-'support@'$VIRTUAL_HOST} \
	--account-name=${WP_USER:-'admin'} \
	--account-mail=${USER_EMAIL:-'support@'$VIRTUAL_HOST} \
	--account-pass=${WP_PASS:-'password'} 

drupal check && \
	drupal module:download admin_toolbar --latest && \ 
	drupal module:install admin_toolbar --latest && \
	drupal module:download devel --latest && \ 
drupal module:install devel --latest
