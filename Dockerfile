# Use official Node.js LTS (Long Term Support) image as base
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first
# This allows Docker to cache npm install layer if dependencies haven't changed
COPY package*.json ./

# Install production dependencies
# --omit=dev skips devDependencies
# --quiet reduces npm install output verbosity
RUN npm install --omit=dev --quiet

# Copy application source code
COPY src ./src

# Create logs directory for winston logger
RUN mkdir -p logs

# Set environment to production
ENV NODE_ENV=production

# Expose port 3000 for the application
EXPOSE 3000

# Set non-root user for security
# This prevents the container from running as root
USER node

# Health check to ensure container is running properly
# Docker will check if the /health endpoint returns 200 OK
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); })"

# Start the application
CMD ["node", "src/app.js"]
