process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const SentryCliPlugin = require('@sentry/webpack-plugin');

// Only generate sentry releases when SENTRY_RELEASE is available
if (process.env.SENTRY_RELEASE) {
  const release = process.env.SENTRY_RELEASE

  environment.plugins.append('sentry', new SentryCliPlugin({
    ignore: ['node_modules', 'webpack.config.js', 'vendor'],
    include: ['app/javascript', 'public/assets'],
    release,
    setCommits: {
      commit: release,
      repo: 'debtcollective/fundraising',
    }
  }))
}


module.exports = environment.toWebpackConfig()
