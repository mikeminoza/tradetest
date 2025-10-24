# ------------------------------
# Stage 1 - Build frontend using Vite
# ------------------------------
FROM node:18 AS frontend

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app and build the frontend
COPY . .
RUN npm run build


# ------------------------------
# Stage 2 - Backend (Laravel + PHP + Composer)
# ------------------------------
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip libpng-dev libonig-dev libxml2-dev zip libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy Laravel app files (excluding node_modules) from frontend stage
COPY --from=frontend /app /var/www/html

# Copy the built Vite assets separately to ensure manifest exists
COPY --from=frontend /app/public/build /var/www/html/public/build

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Ensure Laravel has the right permissions for storage & cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Clear caches just in case
RUN php artisan config:clear \
 && php artisan cache:clear \
 && php artisan route:clear

# Expose port
EXPOSE 8000

# Start Laravel server and run migrations
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
