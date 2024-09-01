# Use an official node image as the base image
FROM node:16 AS build

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy the entire project
COPY . .

# Build the React app
RUN npm run build

# Use an nginx image to serve the build
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
