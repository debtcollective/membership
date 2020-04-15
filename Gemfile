source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.2.2'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '4.3.3'
# Use SCSS for stylesheets
gem 'sassc', '~> 1.11', '>= 1.11.4'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'redis-namespace', '~> 1.6'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'ffi', '~> 1.9', '>= 1.9.25'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# front-end libraries
gem 'react_on_rails', '~> 11.3'
gem 'mini_racer', platforms: :ruby

# Payments
gem 'stripe', '5.17.0'

# Authentication
gem 'jwt', '~> 2.2.1'
gem 'recaptcha', '~> 5.2', '>= 5.2.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Delayed jobs
gem 'sidekiq', '~> 6.0'
gem 'sidekiq-scheduler', '~> 3.0'

gem "health_check", github: 'ianheggie/health_check', :ref => '0b799ea'
gem 'sentry-raven', '~> 2.12', '>= 2.12.3'

# Performance monitoring
gem 'skylight', '4.2.3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug', '~> 3.9.0'
  gem 'standard', '~> 0.2.0'
  gem 'dotenv-rails', '2.7.5'
  gem 'faker', '~> 2.1', '>= 2.1.2'
  gem 'factory_bot', '~> 5.0', '>= 5.0.2'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'solargraph', '~> 0.38.0'
end

group :test do
  # TODO: Change when rspec 4 is released
  gem "climate_control", "~> 0.2.0"
  gem 'capybara', '~> 3.28'
  gem 'capybara-screenshot', '~> 1.0', '>= 1.0.23'
  gem 'rspec-core', git: 'https://github.com/rspec/rspec-core'
  gem 'rspec-expectations', git: 'https://github.com/rspec/rspec-expectations'
  gem 'rspec-mocks', git: 'https://github.com/rspec/rspec-mocks'
  gem 'rspec-rails', git: 'https://github.com/rspec/rspec-rails', branch: '4-0-dev'
  gem 'rspec-support', git: 'https://github.com/rspec/rspec-support'
  gem 'selenium-webdriver', '~> 3.142', '>= 3.142.3'
  gem 'shoulda-matchers', '~> 4.1', '>= 4.1.2'
  gem 'stripe-ruby-mock', '~> 2.5.8', :require => 'stripe_mock'
  gem 'timecop', '~> 0.9.1'
  gem 'webdrivers', '~> 4.1', '>= 4.1.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
