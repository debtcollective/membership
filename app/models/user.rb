# frozen_string_literal: true

class User < ApplicationRecord
  USER_ROLES = { admin: 'admin', user: 'user' }.freeze
end
