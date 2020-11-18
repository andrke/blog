FROM node:14.4.0-alpine3.10 as dependencies
USER root
WORKDIR /frontend
COPY . /frontend
ARG API_URL
ENV REACT_APP_HOST_IP_ADDRESS $API_URL
RUN yarn
RUN yarn build

FROM nginx:latest AS release
COPY --from=dependencies /frontend/build ./var/www/frontend
COPY nginx/nginx-proxy.conf /etc/nginx/conf.d