# Multi-stage build for Laravel application
FROM php:8.1-fpm-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx \
    supervisor \
    mysql-client

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www/html

# Copy composer files
COPY composer.json composer.lock ./

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy application files
COPY . .

# Copy nginx configuration
COPY nginx_app.conf /etc/nginx/conf.d/default.conf

# Copy supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Build stage for assets
FROM node:16-alpine AS assets

WORKDIR /var/www/html

# Copy package files
COPY package.json package-lock.json ./

# Install Node.js dependencies
RUN npm ci --only=production

# Copy source files
COPY resources/ ./resources/
COPY webpack.mix.js tailwind.config.js ./

# Build assets
RUN npm run production

# Final stage
FROM base AS production

# Copy built assets from assets stage
COPY --from=assets /var/www/html/public/mix-manifest.json /var/www/html/public/
COPY --from=assets /var/www/html/public/css/ /var/www/html/public/css/
COPY --from=assets /var/www/html/public/js/ /var/www/html/public/js/

# Create .env file if it doesn't exist
RUN php -r "file_exists('.env') || copy('.env.example', '.env');"

# Generate application key
RUN php artisan key:generate --no-interaction

# Optimize Laravel
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 