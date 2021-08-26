FROM node:lts-alpine3.14
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm test
EXPOSE 8080
CMD [ "node", "start.js" ]
