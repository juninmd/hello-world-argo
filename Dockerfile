# Use Bun's official image
FROM oven/bun:1.1.29-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile --production

# Copy source code
COPY . ./.

# Build the application
RUN bun build src/index.ts --outdir ./dist --target bun

# Create a non-root user and switch to it
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

USER nextjs

# Start the application
CMD ["bun", "run", "dist/index.js"]
