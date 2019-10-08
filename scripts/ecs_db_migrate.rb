#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'active_support/core_ext/object/blank'

cluster = ENV['ECS_CLUSTER']
container = ENV['ECS_SERVICE']

errors = [cluster.blank? ? 'ECS_CLUSTER' : nil, container.blank? ? 'ECS_SERVICE' : nil].compact

if errors.any?
  message = "ABORTED! #{errors.join(', ')} not present"
  warn(message)
  exit(false)
end

overrides = {
  containerOverrides: [{
    name: container,
    command: ['bundle', 'exec', 'rake', 'db:migrate']
  }]
}

migration_command = 'aws ecs run-task ' \
                    '--started-by db-migrate ' \
                    "--cluster #{cluster} " \
                    "--task-definition #{cluster} " \
                    "--overrides '#{overrides.to_json}' "

puts migration_command

puts ''

puts `#{migration_command}`
