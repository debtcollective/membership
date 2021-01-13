import faker from 'faker'

describe('Membership Spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders donation widget', () => {
    cy.visit('/test/widget/membership')
    cy.contains('PAY MONTHLY DUES', { matchCase: false })
  })
})
