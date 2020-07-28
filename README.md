<div align="center">
  <h1>FUNDRAISING</h1>
</div>

Membership is a simple app for non profit organizations, that allows users to create an account using [Discourse](https://discourse.org) and donate to the organization. It contains the following features:

- Simple donations payment management through Stripe.
- One time donations through anonymous accounts.
- One time donations through user accounts.
- User subscriptions based on billing plans.
- User dashboard to manage their own subscription.
- Simple statistics for the Organization around donations.
- Organization dashboard to create subcription plans.
- Organization dashboard to manage subscribed users.

<hr />

[![CircleCI](https://circleci.com/gh/debtcollective/membership.svg?style=svg)](https://circleci.com/gh/debtcollective/membership)

## Table of contents

- [Getting started](#getting-started)
  * [Setup](#setup)
  * [System dependencies](#system-dependencies)
  * [Configuration](#configuration)
  * [User sessions](#user-sessions)
- [Developer notes](#developer-notes)
  * [Ruby 2.7 deprecations warnings](#ruby-27-deprecations-warnings)
  * [Running Forego](#running-forego)
  * [Formatting](#formatting)

## Getting started

### Setup

```bash
bundle install # install gems
yarn install # install packages
rake db:create # create database
rake db:migrate # migrate database
rake db:seed # seed database

# run project with
forego start
```

### System dependencies

You'll need to have installed the following dependencies installed, if you don't want to use the provided Docker containers.

- Ruby
- Node
- PostgreSQL
- Forego `brew install forego`

An instance of PostgresSQL needs to be actively running.
_Note:_ MacOS users can use the [Postgres app](https://postgresapp.com).

### Configuration

Have a ruby version installed, you can learn more about how to use multiple versions of Ruby installed in your computer with [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io).

To get started with the app, clone the repo and then install the needed gems:

```bash
$ bundle install
```

Next, migrate the database:

```bash
$ bundle exec rake db:migrate
```

Finally, run the test suite to verify that everything is working correctly (This project uses [rspec](http://rspec.info)):

```bash
$ bundle exec rspec
```

If the test suite passes, you'll be ready to run the app in a local server:

```bash
$ forego start -f <Procfile>
```

**Note** [Learn more about using Forego on your local machine](#running-forego)

1. `Procfile.dev`: Starts the Webpack Dev Server and Rails with Hot Reloading.
2. `Procfile.hot`: Starts the Rails server and the webpack server to provide hot reloading of assets, JavaScript and CSS.
3. `Procfile.static`: Starts the Rails server and generates static assets that are used for tests.
4. `Procfile.spec`: Starts webpack to create the static files for tests. _Good to know:_ If you want to start `rails s` separately to debug in pry, then run `Procfile.spec` to generate the assets and run rails s in a separate console.

### User sessions

We use cookie based authentication across subdomains instead of creating sessions between apps. This provides a better experience and fixes out of sync sessions between Discourse and other apps. [Read how to setup a user session](https://github.com/debtcollective/discourse-debtcollective-sso/blob/od/v2/README.md).

## Developer notes

### Ruby 2.7 deprecations warnings

Rails and other gems have to fix warnings in Ruby 2.7. Until that happens, we can supress these warnings by passing `RUBYOPT='-W:no-deprecated -W:no-experimental'` environment variable when running commands. ex `RUBYOPT='-W:no-deprecated -W:no-experimental' bundle exec rake db:migrate`

We have added a make command to run specs with this env variable set, so you can run `make spec` and it will run without warnings.

### Running Forego

[Forego](https://github.com/ddollar/forego) has the following note around installing this gem.

> Ruby users should take care not to install forego in their project's Gemfile.

Therefore as a developer, you're expected to run

```bash
 gem install forego
```

And run the commands using your gemset installation of forego.

### Formatting

We are using [Standard](https://github.com/testdouble/standard) that is a wrapper on top of Rubocop with a predefined set of Rules. If you use VS Code you will want to install [vscode-ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby) extension and enable formatting on save.

To enable formatting on save add these lines to your `settings.json`.

```json
{
  "[ruby]": {
    "editor.formatOnSave": true
  },
  "ruby.lint": {
    "rubocop": true
  },
  "ruby.format": "rubocop",
  "editor.formatOnSaveTimeout": 5000
}
```

We're also using [standardjs](https://standardjs.com) and [prettier](https://prettier.io) to standarize our JavaScript development. This is running automatically on a **before commit** hook using [husky](https://github.com/typicode/husky#readme).
