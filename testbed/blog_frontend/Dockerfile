FROM node:14.4.0-alpine3.10 as dependencies
LABEL maintainer="Andres Kepler <andres.kepler@entigo.com>"
USER root
WORKDIR /frontend
COPY . /frontend
ARG API_HOST=backend
ARG API_HOST_PORT=8000
ARG NGINX_LISTEN_PORT=8080
ARG API_URL=http://$API_HOST:$API_HOST_PORT
ENV API_URL $API_URL
ENV API_HOST $API_HOST
ENV API_HOST_PORT $API_HOST_PORT
ENV NGINX_LISTEN_PORT $NGINX_LISTEN_PORT

RUN yarn
RUN yarn build

FROM nginx:latest AS release
COPY --from=dependencies /frontend/build ./var/www/frontend
COPY nginx/nginx-proxy.conf.template  /etc/nginx/templates/