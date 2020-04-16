FROM ruby:2.7.1

# install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev

ENV NODE_ENV=production RAILS_ENV=production

# install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g yarn

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# install gems
ADD Gemfile* $APP_HOME/
RUN export BUNDLER_VERSION=$(cat Gemfile.lock | tail -1 | tr -d " ") && \
  gem install bundler
RUN bundle config set without 'development test' && \
  bundle install --path=vendor/bundle

# install forego
RUN curl -O https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.deb
RUN apt install ./forego-stable-linux-amd64.deb

ADD . $APP_HOME

RUN yarn install --check-files
RUN SECRET_KEY_BASE=`bundle exec rake secret` bundle exec rake assets:precompile --trace

# set this until Rails warnings are fixed in Ruby 2.7
ENV RUBYOPT='-W:no-deprecated -W:no-experimental'

ENV PORT=5000
EXPOSE 5000

CMD ["forego", "start"]
