# Dockerfile for Hardhat development environment
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install --only=production && npm install --only=dev

# Copy project files
COPY . .

# Expose Hardhat network port
EXPOSE 8545

# Run tests by default
CMD ["npx", "hardhat", "test"]