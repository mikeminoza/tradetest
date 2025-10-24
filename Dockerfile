# ------------------------------
# Laravel + Vite Single-Stage Dockerfile for Render
# ------------------------------
FROM php:8.2-fpm

# Install system dependencies, PHP extensions, Node & npm
RUN apt-get update && apt-get install -y \
    git curl unzip libpng-dev libonig-dev libxml2-dev zip libzip-dev nodejs npm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copy the entire project
COPY . .

# Install frontend dependencies and build assets
RUN npm install && npm run build

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ensure Laravel has the right permissions for storage & cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose port 8000 for Laravel serve
EXPOSE 8000

# Runtime: run migrations, clear caches, and start Laravel server
CMD php artisan migrate --force && \
    php artisan config:clear && \
    php artisan cache:clear && \
    php artisan route:clear && \
    php artisan serve --host=0.0.0.0 --port=8000
