# Stage 1 - Build frontend using Vite
FROM node:18 AS frontend

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2 - Backend (Laravel + PHP + Composer)
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip libpng-dev libonig-dev libxml2-dev zip libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy Laravel app (including built assets from the previous stage)
COPY --from=frontend /app /var/www/html

# Install PHP dependencies (use --no-interaction for CI/CD)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ensure Laravel has the right permissions for storage & cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port
EXPOSE 8000

# Start Laravel server + run migrations
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
