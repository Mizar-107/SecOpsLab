# VULNERABLE Dockerfile - DO NOT USE IN PRODUCTION
# This image has intentional security issues for demonstration

FROM nginx:1.19
# ❌ Outdated base image with known CVEs

# ❌ Running as root (default for nginx:1.19)
USER root

# ❌ No specific version pinning for packages
RUN apt-get update && apt-get install -y curl

# Copy static files
COPY src/ /usr/share/nginx/html/

# ❌ Default nginx config (not hardened)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
