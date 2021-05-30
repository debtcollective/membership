class AddMetadataToSubscriptions < ActiveRecord::Migration[6.1]
  def up
    Subscription.find_each do |subscription|
      user = subscription.user
      donation = subscription.donations.last

      next unless donation

      subscription.metadata = {
        payment_provider: "stripe",
        payment_method: {
          type: "card",
          last4: donation.charge_data&.[]("source")&.[]("last4"),
          card_id: donation.charge_data&.[]("source")&.[]("id"),
          customer_id: user.stripe_id
        }
      }

      subscription.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
