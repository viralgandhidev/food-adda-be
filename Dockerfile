FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Install netcat for health checks and entrypoint script
RUN apk add --no-cache netcat-openbsd

# Copy built files
COPY --from=build /app/build ./build
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/src/infrastructure/database/migrations ./src/infrastructure/database/migrations

# Copy and make entrypoint script executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3001

# Use entrypoint script to run migrations before starting
ENTRYPOINT ["/entrypoint.sh"]









