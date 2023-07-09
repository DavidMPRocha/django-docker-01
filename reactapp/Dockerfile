FROM alpine:3.17
ENV NODE_VERSION 20.3.1

WORKDIR /reactap

COPY package.json .

RUN apk add --update nodejs npm
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]