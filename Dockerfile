# ---- Build stage: compile Tailwind CSS with the standalone CLI ----
FROM node:24-alpine AS build

WORKDIR /app

# Install deps first for better layer caching
COPY package*.json ./
RUN npm ci

# Scan index.html and emit only the used utilities into dist/output.css
COPY . .
RUN npm run build && cp index.html dist/

# ---- Serve stage: lightweight Node static file server ----
FROM node:24-alpine AS serve

WORKDIR /app

# `serve` is a small static web server (nginx replacement)
RUN npm install -g serve

# Only the built page + CSS are needed at runtime
COPY --from=build /app/dist ./dist

EXPOSE 3000

# -s = single-page fallback, -l = listen port
CMD ["serve", "-s", "dist", "-l", "3000"]
