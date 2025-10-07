# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install --only=production

# Copy app source code
COPY . .

# Expose port
EXPOSE 8080

# Start the application
CMD ["npm", "start"]
