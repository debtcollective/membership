process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const SentryCliPlugin = require('@sentry/webpack-plugin');

// Only generate sentry releases when building master
if (process.env.CI && process.env.CIRCLE_BRANCH === 'master') {
  const release = (process.env.CIRCLE_SHA1).substring(0, 7)

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
