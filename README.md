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
  - [Setup](#setup)
  - [System dependencies](#system-dependencies)
  - [Configuration](#configuration)
  - [User sessions](#user-sessions)
- [Developer notes](#developer-notes)
  - [Ruby 2.7 deprecations warnings](#ruby-27-deprecations-warnings)
  - [Running Forego](#running-forego)
  - [Formatting](#formatting)

## Getting started

### Setup

```bash
cp .env.sample .env # copy .env file
bundle install # install gems
yarn install # install packages
rake db:create # create database
rake db:migrate # migrate database
rake db:seed # seed database

# run project with
forego start
```

At this point, you should be able to see the app at http://membership.lvh.me:5000

### Dotenv

We are using Dotenv to set our environment variables. Once you copy the `.env.sample` file to `.env` you need to replace a few variables there, most of them will work with defaults.

#### Stripe

You can get the Stripe keys by registering for a free Stripe account and generating test keys. Here's a link to their Docs on how to obtain these keys https://stripe.com/docs/keys#obtain-api-keys.

#### Google reCAPTCHA

In order to obtain this key, you need to go to this address and generate one https://www.google.com/recaptcha/admin/create. Be sure to use the reCAPTCHA V2 and select the I'm not a robot" checkbox option. Also, set the correct domain names the app is running on, these are `membership.lvh.me` and `localhost`.

If you need help to get some of these key right or setting this up, please ask other devs for help.

### System dependencies

You'll need to have installed the following dependencies installed, if you don't want to use the provided Docker containers.

- Ruby
- Node
- PostgreSQL
- Forego `brew install forego`

An instance of PostgresSQL needs to be actively running.
_Note:_ MacOS users can use the [Postgres app](https://postgresapp.com).

### Running tests

```bash
$ bundle exec rspec
```

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

### Solargraph

Install [Ruby Solargraph](https://marketplace.visualstudio.com/items?itemName=castwide.solargraph) VSCode extension to enable autocompletion.

### Formatting

We are using [Standard](https://github.com/testdouble/standard) that is a wrapper on top of Rubocop with a predefined set of Rules. If you use VS Code you will want to install [vscode-ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby) extension and enable formatting on save.

To enable formatting on save add these lines to your `settings.json`.

```json
{
  "[ruby]": {
    "editor.formatOnSave": true
  },
  "ruby.lint": {
    "standard": true
  },
  "ruby.format": "standard",
  "ruby.useLanguageServer": true,
  "editor.formatOnSaveTimeout": 5000
}
```

We're also using [standardjs](https://standardjs.com) and [prettier](https://prettier.io) to standarize our JavaScript development. This is running automatically on a **before commit** hook using [husky](https://github.com/typicode/husky#readme).

### Codecov

We use [codecov](https://github.com/codecov/codecov-ruby) for our test coverage metrics. In CI we need to provide a `CODECOV_TOKEN` env variable to upload code coverage stats correctly.
