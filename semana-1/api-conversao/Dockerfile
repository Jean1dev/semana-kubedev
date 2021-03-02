FROM node:14.11.0-alpine3.11

WORKDIR /app

COPY package.json ./app

RUN npm install

COPY . . 

EXPOSE 8080

CMD ["npm", "start"]