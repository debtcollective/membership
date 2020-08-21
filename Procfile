web: rails s
sidekiq: bundle exec sidekiq -C ./config/sidekiq.yml
client: sh -c 'rm -rf public/packs/* || true && bundle exec rake react_on_rails:locale && bin/webpack -w'
