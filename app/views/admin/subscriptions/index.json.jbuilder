# frozen_string_literal: true

json.array! @subscriptions, partial: 'subscriptions/subscription', as: :subscription
