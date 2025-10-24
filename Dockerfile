# ---------------------------
# 1️⃣ Stage: Build Frontend
# ---------------------------
FROM node:18 AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build


# ---------------------------
# 2️⃣ Stage: PHP + Laravel
# ---------------------------
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev zip curl \
 && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# ✅ Copy built Vite assets from the previous (build) stage
COPY --from=build /app/public/build /var/www/html/public/build

RUN composer install --no-dev --optimize-autoloader

# ✅ Run setup and serve Laravel
CMD php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear \
 && php artisan optimize:clear \
 && php artisan storage:link \
 && php artisan migrate --force \
 && php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000
