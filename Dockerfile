FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build || echo "skip build if not configured"

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app ./
RUN npm ci --omit=dev
EXPOSE 3001
CMD ["npm","run","start"]








