FROM ruby:2.7.2

# install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev

ENV NODE_ENV=production RAILS_ENV=production

# install node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g yarn

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# install gems
ADD Gemfile* $APP_HOME/
RUN export BUNDLER_VERSION=$(cat Gemfile.lock | tail -1 | tr -d " ") && \
  gem install bundler
RUN bundle config set without 'development test' && \
  bundle config set path 'vendor/bundle' && \
  bundle install

# install forego
RUN curl -LO https://github.com/viranch/forego/releases/download/20211019/forego-linux-amd64.tgz
RUN tar -C /usr/local/bin/ -zxf forego-linux-amd64.tgz

ADD . $APP_HOME

# set sentry release
ARG sentry_release=""
ARG sentry_auth_token=""
ENV SENTRY_RELEASE=${sentry_release}
ENV SENTRY_AUTH_TOKEN=${sentry_auth_token}

RUN yarn install --check-files
RUN env SECRET_KEY_BASE=`bundle exec rake secret` bundle exec rake assets:precompile --trace

ENV PORT=5000
EXPOSE 5000

CMD ["forego", "start", "-f", "Procfile.prod"]
