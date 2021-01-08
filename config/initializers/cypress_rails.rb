return unless Rails.env.test?

CypressRails.hooks.before_server_start do
  FactoryBot.create(:default_fund)
end

CypressRails.hooks.after_transaction_start do
  DatabaseCleaner.strategy = :truncation, {except: %w[funds]}
  DatabaseCleaner.clean
  # Called after the transaction is started (at launch and after each reset)
end

CypressRails.hooks.after_state_reset do
  # Triggered after `/cypress_rails_reset_state` is called
end

CypressRails.hooks.before_server_stop do
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end
