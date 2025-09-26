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

# Copy seed images into storage/public
COPY storage_seed/ /var/www/html/storage/app/public/

# Ensure storage and cache directories exist
RUN mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Expose port
EXPOSE 8080

# Run Laravel setup and start server
CMD ["sh", "-c", "\
    # Generate APP_KEY if not set
    if [ -z \"$APP_KEY\" ]; then php artisan key:generate; fi && \
    # Ensure storage and cache directories
    mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache && \
    chown -R www-data:www-data storage bootstrap/cache && chmod -R 775 storage bootstrap/cache && \
    # Ensure symlink exists
    php artisan storage:link && \
    # Copy seed images into volume if not already present
    cp -rn /var/www/html/storage/app/public/* /var/www/html/storage/app/public/ && \
    echo '🎉 Laravel app ready!' && \
    # Start PHP server with public as document root
    php -S 0.0.0.0:8080 -t public \
"]
