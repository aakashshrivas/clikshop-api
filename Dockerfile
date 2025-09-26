# Use official PHP 8.2 FPM image
FROM php:8.2-fpm

# Install system dependencies + MySQL client
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd exif pdo_mysql bcmath mbstring xml zip opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Ensure storage and cache directories exist
RUN mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Expose port
EXPOSE 8080

# Run Laravel setup + DB import only first time + migrations + seed
CMD ["sh", "-c", "\
    # Generate APP_KEY if not exists
    if [ -z \"$APP_KEY\" ]; then php artisan key:generate; fi && \
    # Ensure storage directories
    mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache && chmod -R 775 storage bootstrap/cache && \
    php artisan storage:link && \
    # Import DB only once
    if [ -f /var/www/html/db.sql ] && [ ! -f /var/www/html/.db_imported ]; then \
        echo '📥 Importing database from db.sql...'; \
        mysql --ssl=0 -h $MYSQLHOST -P $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE < /var/www/html/db.sql; \
        touch /var/www/html/.db_imported; \
        echo '✅ Database import completed.'; \
    else \
        echo '⏭️ Skipping DB import (already done or file missing).'; \
    fi && \
    echo '🎉 Laravel app ready!' && \
    php artisan serve --host=0.0.0.0 --port=8080 \
"]
