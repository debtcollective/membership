process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const SentryCliPlugin = require('@sentry/webpack-plugin');

environment.plugins.append('sentry', new SentryCliPlugin({
  include: ['app/javascript', 'public/assets'],
  ignore: ['node_modules', 'webpack.config.js', 'vendor'],
  setCommits: {
    repo: 'debtcollective/fundraising',
    auto: true
  }
}))

module.exports = environment.toWebpackConfig()
