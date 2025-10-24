# ---------------------------
# 1️⃣ Stage: Build Frontend
# ---------------------------
FROM node:18 AS build

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build Vite assets for production
RUN npm run build


# ---------------------------
# 2️⃣ Stage: PHP + Laravel
# ---------------------------
FROM php:8.2-fpm

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl \
 && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Copy Composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy all Laravel files
COPY . .

# Copy built Vite assets from the previous build stage
COPY --from=build /app/public/build /var/www/html/public/build

# Install PHP dependencies and optimize Laravel
RUN composer install --no-dev --optimize-autoloader \
 && php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear \
 && php artisan optimize

# Expose port 8000 for Render
EXPOSE 8000

# Run migrations automatically, then start Laravel
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
