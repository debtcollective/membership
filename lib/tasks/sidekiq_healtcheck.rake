# frozen_string_literal: true

namespace :active_job_sidekiq_queue do
  desc 'Check queue status of SideKiq'
  SIDEKIQ_MAX_WAIT_QUEUE = ENV['SIDEKIQ_MAX_WAIT_QUEUE'].presence || 100
  SIDEKIQ_MAX_RETRY_QUEUE = ENV['SIDEKIQ_MAX_RETRY_QUEUE'].presence || 20

  task check_health: :environment do
    messages = []
    if Sidekiq::Queue.new.size.to_i > SIDEKIQ_MAX_WAIT_QUEUE.to_i
      messages << "SideKiq waiting queue count exceeds #{SIDEKIQ_MAX_WAIT_QUEUE}. Currently, #{Sidekiq::Queue.new.size}. Please check SideKiq."
    end

    if Sidekiq::RetrySet.new.size.to_i > SIDEKIQ_MAX_RETRY_QUEUE.to_i
      messages << "SideKiq retry queue count exceeds #{SIDEKIQ_MAX_RETRY_QUEUE}. Currently, #{Sidekiq::RetrySet.new.size}. Please check SideKiq."
    end

    if messages.present?
      raise messages.join("\n") # raise error and send the messages to bug tracker
    end
  end
end
