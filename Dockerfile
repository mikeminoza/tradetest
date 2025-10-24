# ---------------------------
# 1️⃣ Stage: Build Frontend (Vite)
# ---------------------------
FROM node:18 AS frontend

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source and build assets
COPY . .
RUN npm run build  # This generates files in public/build


# ---------------------------
# 2️⃣ Stage: Backend (Laravel + PHP)
# ---------------------------
FROM php:8.2-fpm AS backend

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip libpq-dev libonig-dev libzip-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath

# Copy Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy application source
COPY . .

# ✅ Copy built Vite assets from the frontend build stage
COPY --from=frontend /app/public/build ./public/build

# Install Laravel dependencies (no dev)
RUN composer install --no-dev --optimize-autoloader

# ✅ Clear and optimize Laravel caches
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear && \
    php artisan optimize

# ✅ Optional: link storage folder (common in Laravel)
RUN php artisan storage:link || true

# ✅ Run migrations automatically before serving
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000
