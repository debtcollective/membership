# frozen_string_literal: true

json.array! @donations, partial: 'donations/donation', as: :donation
