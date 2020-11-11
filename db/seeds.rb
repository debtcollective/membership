# frozen_string_literal: true

# Funds
[
  {
    name: "General Debt Collective Fund",
    slug: Fund::DEFAULT_SLUG
  },
  {
    name: "Anti-Eviction Fund",
    slug: "anti-eviction"
  }
].each do |data|
  fund = Fund.find_or_initialize_by(slug: data[:slug])

  fund.name = data[:name]
  fund.save
end
