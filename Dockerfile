FROM ruby:2.6.4

# install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev

# install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g yarn

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN export BUNDLER_VERSION=$(cat Gemfile.lock | tail -1 | tr -d " ") && \
  gem install bundler

RUN bundle install
RUN yarn install --check-files

ADD . $APP_HOME

EXPOSE 3000
ENV RAILS_ENV production

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
