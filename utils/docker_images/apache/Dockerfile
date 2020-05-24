# from https://www.drupal.org/docs/8/system-requirements/drupal-8-php-requirements
FROM php:7.3-apache-stretch
# TODO switch to buster once https://github.com/docker-library/php/issues/865 is resolved in a clean way (either in the PHP image or in PHP itself)
# persistent dependencies

# install the PHP extensions we need
RUN set -eux; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
    libmagickwand-dev \
    libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libzip-dev \
		git \
		# Ghostscript is required for rendering PDF previews
    		ghostscript \
	; \
	\
  # Install Composer, Drush7, and Drush8
  # https://modulesunraveled.com/blog/install-drush-7-and-8-and-automatically-switch-versions-based-project
  # Install Composer
  curl -sS https://getcomposer.org/installer | php && \
      mv composer.phar /usr/local/bin/composer && \
    echo "COMPOSER VERSION >>>> $(composer --version)"; \
  \
	docker-php-ext-configure gd \
		--with-freetype-dir=/usr \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
    bcmath \
    exif \
    mysqli \
	; \
		pecl install imagick-3.4.4; \
  	docker-php-ext-enable imagick; \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 c}' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
    echo 'memory_limit = 64MB'; \
  } > /usr/local/etc/php/conf.d/mem-limit.ini

RUN set -eux; \
	a2enmod rewrite expires; \
	\
# https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html
	a2enmod remoteip; \
	{ \
		echo 'RemoteIPHeader X-Forwarded-For'; \
# these IP ranges are reserved for "private" use and should thus *usually* be safe inside Docker
		echo 'RemoteIPTrustedProxy 10.0.0.0/8'; \
		echo 'RemoteIPTrustedProxy 172.16.0.0/12'; \
		echo 'RemoteIPTrustedProxy 192.168.0.0/16'; \
		echo 'RemoteIPTrustedProxy 169.254.0.0/16'; \
		echo 'RemoteIPTrustedProxy 127.0.0.0/8'; \
	} > /etc/apache2/conf-available/remoteip.conf; \
	a2enconf remoteip; \
# https://github.com/docker-library/wordpress/issues/383#issuecomment-507886512
# (replace all instances of "%h" with "%a" in LogFormat)
	find /etc/apache2 -type f -name '*.conf' -exec sed -ri 's/([[:space:]]*LogFormat[[:space:]]+"[^"]*)%h([^"]*")/\1%a\2/g' '{}' +

COPY ./config-docker/apache/ssl.crt /etc/apache2/ssl/ssl.crt
COPY ./config-docker/apache/ssl.key /etc/apache2/ssl/ssl.key
RUN mkdir -p /var/run/apache2/
RUN a2ensite default-ssl
RUN a2enmod ssl

# Get wordpress cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
chmod +x wp-cli.phar && \
mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html/
