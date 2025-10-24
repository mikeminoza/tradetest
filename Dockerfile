# Simple Laravel + Vite Dockerfile for Render
FROM php:8.2-fpm

# Install system dependencies, PHP extensions, Node & npm
RUN apt-get update && apt-get install -y \
    git curl unzip libpng-dev libonig-dev libxml2-dev zip libzip-dev nodejs npm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . .

# Install frontend and build assets, then install PHP dependencies and fix permissions
RUN npm install && npm run build \
    && composer install --no-dev --optimize-autoloader --no-interaction \
    && chown -R www-data:www-data storage bootstrap/cache

# Expose Laravel port
EXPOSE 8000

# Run migrations, clear caches, and serve Laravel at runtime
CMD php artisan migrate --force && \
    php artisan config:clear && \
    php artisan cache:clear && \
    php artisan route:clear && \
    php artisan serve --host=0.0.0.0 --port=8000
