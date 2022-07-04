FROM ruby:3.1.2-alpine

RUN apk update && apk add --no-cache build-base

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment

COPY . .

EXPOSE 9292
CMD bundle exec puma
