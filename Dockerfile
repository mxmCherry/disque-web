FROM ruby:2.5.0-slim-stretch

WORKDIR /disque-web/
EXPOSE 9292

RUN apt-get update
RUN apt-get install --no-install-recommends --no-install-suggests -y build-essential

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment

COPY disque disque
COPY public public
COPY config.ru config.ru
COPY seed.rb seed.rb

CMD bundle exec rackup --host=0.0.0.0 --port=9292
