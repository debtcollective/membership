<div align="center">
  <h2>Membership</h2>
</div>

Membership is a simple app for non profit organizations, that allows users to create an account using [Discourse](https://discourse.org) and donate to the organization. It contains the following features:

- Simple donations payment management through Stripe.
- One time donations through anonymous accounts.
- One time donations through user accounts.
- User dashboard to manage their own subscription.
- Simple statistics for the Organization around donations.
- Organization dashboard to manage memberships.

<hr />

[![CircleCI](https://circleci.com/gh/debtcollective/membership.svg?style=svg)](https://circleci.com/gh/debtcollective/membership)

# Table of contents

- [Table of contents](#table-of-contents)
- [Quick start](#quick-start)
- [Environment Variables](#environment-variables)
  - [Dotenv](#dotenv)
    - [Stripe](#stripe)
    - [Google reCAPTCHA](#google-recaptcha)
- [System dependencies](#system-dependencies)
- [Running tests](#running-tests)
  - [RSpec](#rspec)
  - [Cypress](#cypress)
- [Developer notes](#developer-notes)
  - [User sessions](#user-sessions)
  - [Running Overmind](#running-overmind)
  - [Solargraph](#solargraph)
  - [Formatting with Standard and Prettier](#formatting-with-standard-and-prettier)
  - [Codecov](#codecov)
  - [Preview emails in development with Mailhog](#preview-emails-in-development-with-mailhog)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# Quick start

```bash
cp .env.sample .env # copy .env file
bundle install # install gems
yarn install # install packages
rake db:create # create database
rake db:migrate # migrate database
rake db:seed # seed database

# run project with
overmind s
```

At this point, you should be able to see the app at <http://membership.lvh.me:5000>

# Environment Variables

The easiest way to run the app is by using [Doppler](https://www.doppler.com/). Ask to be added to the project.

You can install it by running `brew install dopplerhq/cli/doppler`. You can can check the [Doppler docs here](https://docs.doppler.com/docs/enclave-installation#local-development), but below is the gist of commands you need to run.

```bash
doppler login
doppler setup
```

To use Doppler to inject environment variables, prepend `doppler run` to commands. You can run [Overmind](#running-the-app-with-overmind) with Doppler running.

```bash
doppler run overmind s
```

We also support [Dotenv](#dotenv) to configure environment variables. But you will need to supply all the secrets manually.

## Dotenv

To do this, just run `cp .env.sample .env` and replace the variables you need. For most of them we are providing defaults that work in development.

### Stripe

You can get the Stripe keys by registering for a free Stripe account and generating test keys. Here's a link to their Docs on how to obtain these keys <https://stripe.com/docs/keys#obtain-api-keys>.

### Google reCAPTCHA

In order to obtain this key, you need to go to this address and generate one <https://www.google.com/recaptcha/admin/create>. Be sure to use the reCAPTCHA V2 and select the I'm not a robot" checkbox option. Also, set the correct domain names the app is running on, these are `membership.lvh.me` and `localhost`.

If you need help to get some of these key right or setting this up, please ask other devs for help.

# System dependencies

You'll need to have installed the following dependencies installed, if you don't want to use the provided Docker containers.

- Ruby
- Node
- PostgreSQL
- Overmind

An instance of PostgresSQL needs to be actively running.
_Note:_ MacOS users can use the [Postgres app](https://postgresapp.com).

# Running tests

## Prepare tests
rails db:test:prepare

## RSpec

```bash
bundle exec rspec
```

## Cypress

```bash
rails cypress:open
```

# Developer notes

## User sessions

We use cookie based authentication across subdomains instead of creating sessions between apps. This provides a better experience and fixes out of sync sessions between Discourse and other apps. [Read how to setup a user session](https://github.com/debtcollective/discourse-debtcollective-sso/blob/master/README.md).

## Running Overmind

[Overmind](https://github.com/DarthSim/overmind) is a process manager for Procfile-based apps.

You can install on OSX by running `brew install tmux overmind`.

A cool feature that Overmind has is that it allows you to connect to specific process terminal via tmux. This is really
useful when debugging apps. If you use for example `binding.pry`, you can connect to the debugging terminal by running `overmind connect web`

## Solargraph

Install [Ruby Solargraph](https://marketplace.visualstudio.com/items?itemName=castwide.solargraph) VSCode extension to enable autocompletion.

## Formatting with Standard and Prettier

We are using [Standard](https://github.com/testdouble/standard) that is a wrapper on top of Rubocop with a predefined set of Rules. If you use VS Code you will want to install [vscode-ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby) extension and enable formatting on save.

We include a `.vscode` folder with configuration specific to this project.

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

## Codecov

We use [codecov](https://github.com/codecov/codecov-ruby) for our test coverage metrics. In CI we need to provide a `CODECOV_TOKEN` env variable to upload code coverage stats correctly.

## Preview emails in development with Mailhog

We use [Mailhog](https://github.com/mailhog/MailHog) to preview emails in development. You can install it with brew by running `brew install mailhog`. Once you have it installed, you can run it in a separated terminal session with `mailhog`.

You can preview the email by going to http://127.0.0.1:8025

## Data migrations with the data_migrate gem

We use [data_migrate](https://github.com/ilyakatz/data-migrate) to handle data migrations, instead of having many one-off scripts. You can generate a data migration by running.

```bash
rails g data_migration migration_name
```

and apply the data migrations by running.

```bash
rails data:migrate
```
