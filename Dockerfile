FROM php:8.2-cli

# Install system dependencies + supervisor
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    zip unzip git curl default-mysql-client \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install and configure PHP extensions
# Use a single RUN layer for dependency installation and extension enabling to save space
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd exif pdo_mysql bcmath mbstring xml zip opcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY . .

# Copy supervisord config
COPY ./docker/supervisord.conf /etc/supervisord.conf

# Make startup.sh executable
# It's better to use the full path here for clarity, assuming it's copied to the working dir if needed
RUN chmod +x docker/startup.sh

# Install PHP dependencies
# Run this as root for the build process
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Permissions: Grant ownership to the non-root user that will run the app (www-data)
RUN mkdir -p storage/framework/{cache,sessions,testing,views} bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Switch to the non-root user for security and runtime consistency
# The container will now run its main CMD as this user (UID 33)
USER www-data

EXPOSE $PORT

# Start supervisor as the non-root user
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]