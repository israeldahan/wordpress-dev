FROM node:10

RUN npm install -g gatsby-cli

#COPY gatsby/ /usr/src/app/

WORKDIR /usr/src/app

RUN npm install

EXPOSE 8000

#CMD tail -f /dev/null
CMD ["gatsby", "develop", "-H", "0.0.0.0"]


