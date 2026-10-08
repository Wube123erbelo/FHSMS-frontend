# syntax=docker/dockerfile:1

# Build the React/Vite frontend
FROM node:20-alpine AS build

WORKDIR /app

# package.json is at the repository root
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the frontend project
COPY . ./

# API base URL
# Leave empty for same-domain API requests such as /api
ARG VITE_API_BASE_URL=""
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Build the Vite application
RUN npm run build


# Production web server
FROM caddy:2-alpine AS runtime

# Copy the built frontend
COPY --from=build /app/dist /srv

# Caddyfile is at the repository root
COPY Caddyfile /etc/caddy/Caddyfile

# Server configuration
ENV SITE_ADDRESS=":80" \
    API_UPSTREAM="api:8080"

# HTTP and HTTPS
EXPOSE 80 443

# Start Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]