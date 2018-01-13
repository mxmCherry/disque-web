FROM ruby:2.5.0-slim-stretch

EXPOSE 9292

RUN apt-get update
RUN apt-get install --no-install-recommends --no-install-suggests -y build-essential

WORKDIR /disque-web/
COPY disque_web.rb config.ru Gemfile Gemfile.lock seed.rb ./
RUN bundle install --deployment

CMD bundle exec rackup --host=0.0.0.0 --port=9292
