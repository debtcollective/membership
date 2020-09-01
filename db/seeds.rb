# frozen_string_literal: true

# Plans
[
  {
    amount: 5,
    name: "Basic",
    headline: "\tHelp us fund our mission.",
    description: <<~HEREDOC
      This monthly donation helps keep our platform up and running and our team working one-on-one with folks in debt.
    HEREDOC
  },
  {
    amount: 20,
    name: "Sustaining",
    headline: "Push us closer to future projects.",
    description: <<~HEREDOC
      This level helps us plan for future actions and initiatives, as well as grow and develop new strategies only possible with the right level of funds.
    HEREDOC
  }
].each do |data|
  plan = Plan.find_or_initialize_by(name: data[:name]) { |p|
    p.amount = data[:amount]
    p.headline = data[:headline]
    p.description = data[:description]
  }

  plan.save
end

# Funds
[{name: "Debt Collective", slug: Fund::DEFAULT_SLUG}].each do |data|
  fund = Fund.find_or_initialize_by(slug: data[:slug])

  fund.name = data[:name]

  fund.save
end
