# ----------------------------
# Stage 1: PHP Dependencies
# ----------------------------
FROM php:8.2-fpm AS php-base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    zip unzip git curl default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd exif pdo_mysql bcmath mbstring xml zip opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Copy project files
COPY . .

# Install PHP dependencies (optimize for prod)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Ensure storage/cache permissions
RUN mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache


# ----------------------------
# Stage 2: Nginx + Supervisor
# ----------------------------
FROM nginx:alpine AS prod

# Install PHP FPM + supervisor
RUN apk add --no-cache bash supervisor

# Copy Laravel app from build stage
COPY --from=php-base /var/www/html /var/www/html

# Nginx config
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf

# Supervisor config (runs PHP-FPM + setup tasks)
COPY ./docker/supervisord.conf /etc/supervisord.conf

WORKDIR /var/www/html

# Expose Railway dynamic port
EXPOSE $PORT

# Start supervisor (which runs PHP-FPM + Nginx + artisan tasks)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
