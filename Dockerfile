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

# run make on host for this:

# ADD https://cdn.jsdelivr.net/npm/vue@2.5.13                                      public/dist/vue.js
# ADD https://unpkg.com/vue-router@3.0.1/dist/vue-router.js                        public/dist/vue-router.js
# ADD https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.3/css/bootstrap.min.css public/dist/bootstrap.css

CMD bundle exec rackup --host=0.0.0.0 --port=9292
