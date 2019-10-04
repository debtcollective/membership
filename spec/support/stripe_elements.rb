# frozen_string_literal: true

module StripeElements
  def fill_stripe_elements(card:, expiry: '1234', cvc: '123', postal: '12345')
    using_wait_time(10) do
      frame = find('#card-element > div > iframe')
      within_frame(frame) do
        card.to_s.chars.each do |piece|
          find_field('cardnumber').send_keys(piece)
        end

        find_field('exp-date').send_keys expiry
        find_field('cvc').send_keys cvc
        find_field('postal').send_keys postal
      end
    end
  end
end

RSpec.configure do |config|
  config.include StripeElements, type: :feature
end
