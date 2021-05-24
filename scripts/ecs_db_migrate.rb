#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "active_support/core_ext/object/blank"

cluster = ENV["ECS_CLUSTER"]
service = ENV["ECS_SERVICE"]
task_definition = "#{service}_#{cluster}"

errors = [cluster.blank? ? "ECS_CLUSTER" : nil, service.blank? ? "ECS_SERVICE" : nil].compact

if errors.any?
  message = "ABORTED! #{errors.join(", ")} not present"
  warn(message)
  exit(false)
end

overrides = {
  containerOverrides: [{
    name: service,
    memoryReservation: 128,
    command: ["bundle", "exec", "rails", "db:migrate:with_data"]
  }]
}

migration_command = "aws ecs run-task " \
                    "--started-by db-migrate " \
                    "--cluster #{cluster} " \
                    "--task-definition #{task_definition} " \
                    "--overrides '#{overrides.to_json}' "

puts migration_command

puts ""

puts `#{migration_command}`
