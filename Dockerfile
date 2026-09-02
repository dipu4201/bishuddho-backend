FROM php:8.4-cli

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    && docker-php-ext-install \
        pdo_pgsql \
        bcmath \
        pcntl \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install PHP dependencies first for Docker layer caching
COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --optimize-autoloader \
    --no-scripts

# Copy application
COPY . .

# Laravel permissions
RUN chown -R www-data:www-data \
    storage \
    bootstrap/cache

# Laravel production optimizations
RUN php artisan package:discover --ansi

EXPOSE 10000

CMD php artisan serve \
    --host=0.0.0.0 \
    --port=${PORT:-10000}