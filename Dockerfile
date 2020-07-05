# stage1 as builder
FROM node:latest as builder
# Add a user to the container and provide necessary permissions
RUN useradd -ms /bin/bash zahid

WORKDIR /app

RUN chown -R zahid:zahid /app && chmod 777 /app

USER zahid

# copy the package.json to install dependencies
COPY package.json package-lock.json /app/

# Install the dependencies and make the folder
RUN npm ci && mkdir /app/react-ui && mv /app/node_modules /app/react-ui

WORKDIR /app/react-ui

COPY . /app/react-ui

# Build the project and copy the files
RUN npm run build


FROM nginx:alpine

RUN adduser -S zahid

RUN chown -R zahid /etc/nginx && chmod 777 /etc/nginx && chown -R zahid /usr/share/nginx && chmod 777 /usr/share/nginx

USER zahid

COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf

## Remove default nginx index page
RUN rm -rf /usr/share/nginx/html/*

# Copy from the stahg 1
COPY --from=builder /app/react-ui/build /usr/share/nginx/html

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
