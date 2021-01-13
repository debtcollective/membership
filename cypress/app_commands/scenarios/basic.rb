user = FactoryBot.create(:user, email: "empty_stripe_id@example.com")
stripe_customer = Stripe::Customer.create(email: user.email)
user.update(stripe_id: stripe_customer.id)
