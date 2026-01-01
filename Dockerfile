FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/build ./build
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
# Copy SQL migration files for manual migration runs
COPY src/infrastructure/database/migrations ./src/infrastructure/database/migrations
EXPOSE 3001
CMD ["npm","run","start"]









