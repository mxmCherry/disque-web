FROM ruby:2.5.0-slim-stretch

RUN apt-get update
RUN apt-get install --no-install-recommends --no-install-suggests -y build-essential

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment

COPY seed.rb seed.rb

CMD bundle exec ruby seed.rb
