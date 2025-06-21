# syntax=docker/dockerfile:1

# Build arguments
ARG PHP_VERSION=8.3
ARG NODE_VERSION=20.18.0
ARG VITE_APP_NAME="Laravel"
# this is PUBLIC key and is used by the frontend. You can ignore the docker warning.
ARG VITE_REVERB_APP_KEY
ARG VITE_REVERB_HOST="localhost"
ARG VITE_REVERB_PORT="8080"
ARG VITE_REVERB_SCHEME="http"

# ============================================
# Base stage - common configuration
# ============================================
FROM serversideup/php:${PHP_VERSION}-fpm-nginx AS base

WORKDIR /var/www/html

# Configure web server and PHP
ENV SSL_MODE="off" \
    AUTORUN_ENABLED="true" \
    PHP_OPCACHE_ENABLE="1" \
    HEALTHCHECK_PATH="/up"

# ============================================
# Dependencies stage - install all dependencies
# ============================================
FROM base AS dependencies

USER root

# Install Node.js
ARG NODE_VERSION
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    corepack enable && \
    rm -rf /tmp/node-build-master

# Copy dependency files only
COPY --chown=www-data:www-data composer.json composer.lock package.json package-lock.json ./

# Install PHP dependencies
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts \
    --no-dev && \
    rm -rf ~/.composer/cache

# Install Node dependencies
RUN npm ci --no-audit --no-fund && \
    rm -rf ~/.npm

# ============================================
# Build stage - compile assets
# ============================================
FROM dependencies AS build

# Build arguments for Vite
ARG VITE_APP_NAME
ARG VITE_REVERB_APP_KEY
ARG VITE_REVERB_HOST
ARG VITE_REVERB_PORT
ARG VITE_REVERB_SCHEME

# Copy application code
COPY --chown=www-data:www-data . .

# Build frontend assets with Vite environment variables
RUN VITE_APP_NAME=$VITE_APP_NAME \
    VITE_REVERB_APP_KEY=$VITE_REVERB_APP_KEY \
    VITE_REVERB_HOST=$VITE_REVERB_HOST \
    VITE_REVERB_PORT=$VITE_REVERB_PORT \
    VITE_REVERB_SCHEME=$VITE_REVERB_SCHEME \
    npm run build

# Clean up Node modules after build
RUN rm -rf node_modules

# ============================================
# Production stage - final image
# ============================================
FROM base AS production

USER root

# Create necessary directories (sqlite) with proper permissions
RUN mkdir -p /var/www/html/dbs && \
    chown -R www-data:www-data /var/www/html/dbs && \
    chmod 775 /var/www/html/dbs

USER www-data

# Copy built application from build stage
COPY --chown=www-data:www-data --from=build /var/www/html /var/www/html

# Expose ports
EXPOSE 8080 8000
