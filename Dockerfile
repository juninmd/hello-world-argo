# Use Bun's official image
FROM oven/bun:1.1.29-alpine AS base

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile --production

# Copy source code
COPY src ./src
COPY tsconfig.json ./

# Build the application
RUN bun build src/index.ts --outdir ./dist --target bun

# Production stage
FROM oven/bun:1.1.29-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S bun -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy built application and dependencies
COPY --from=base --chown=bun:nodejs /app/node_modules ./node_modules
COPY --from=base --chown=bun:nodejs /app/dist ./dist
COPY --from=base --chown=bun:nodejs /app/package.json ./

# Switch to non-root user
USER bun

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ps aux | grep -v grep | grep -q "bun" || exit 1

# Expose port (if needed for monitoring)
EXPOSE 3000

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["bun", "run", "dist/index.js"]
