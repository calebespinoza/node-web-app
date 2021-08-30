FROM node:lts-alpine3.14
WORKDIR /usr/src/app
EXPOSE 8080
COPY package*.json ./
RUN npm install
COPY . .
#RUN npm test
CMD [ "node", "start.js" ]
