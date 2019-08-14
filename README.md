# FUNDRAISING

An instance of PostgresSQL running.
_Note:_ MacOS users can use the [Postgres app](https://postgresapp.com).

## Getting started
### Ruby version
This project runs on `Ruby 2.6.3`

### System dependencies
You'll need to have installed the following dependencies installed, if you don't want to use the provided Docker containers.

- Ruby `2.6.3`
- Node `> 11.12.0`
- PostgreSQL `> 11.4`

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
$ bundle exec rails server
```

## Developer notes

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
