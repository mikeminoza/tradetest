# ---------------------------
# 1️⃣ Stage: Build Frontend
# ---------------------------
FROM node:18 AS build

WORKDIR /app

# Copy and install dependencies
COPY package*.json ./
RUN npm install

# Copy all files and build assets
COPY . .
RUN npm run build


# ---------------------------
# 2️⃣ Stage: PHP + Laravel
# ---------------------------
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl \
 && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Copy Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy Laravel app (except node_modules)
COPY . .

# Copy built Vite assets from previous stage
COPY --from=build /app/public/build /var/www/html/public/build

# Install PHP dependencies and optimize app
RUN composer install --no-dev --optimize-autoloader

# Clear all caches AFTER copying built files
RUN php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear \
 && php artisan optimize:clear \
 && php artisan storage:link

# Expose the Laravel port
EXPOSE 8000

# Run migrations and start server
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
