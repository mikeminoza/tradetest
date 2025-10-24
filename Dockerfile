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

COPY --from=build /app/public/build /var/www/html/public/build

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# ✅ Only clear caches AFTER .env and database are correct
CMD php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear \
 && php artisan optimize:clear \
 && php artisan storage:link \
 && php artisan migrate --force \
 && php artisan serve --host=0.0.0.0 --port=8000
