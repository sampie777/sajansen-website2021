# Package stage
FROM nginx:1.21.3-alpine

# nginx configuration
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./public /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
