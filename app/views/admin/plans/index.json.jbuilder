# frozen_string_literal: true

json.array! @plans, partial: 'plans/plan', as: :plan
