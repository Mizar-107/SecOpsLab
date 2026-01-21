# VULNERABLE Dockerfile - DO NOT USE IN PRODUCTION
# This image has intentional security issues for demonstration

FROM node:14
# ❌ EOL base image with known CVEs

WORKDIR /app

# ❌ Hardcoded secrets in environment
ENV DB_HOST=postgres
ENV DB_USER=admin
ENV DB_PASSWORD=supersecret123
ENV API_KEY=sk-1234567890abcdef

# Copy package files
COPY package*.json ./

# ❌ Running as root (default)
RUN npm install

# Copy source
COPY src/ ./src/

# ❌ No specific user
EXPOSE 3000

CMD ["node", "src/server.js"]
