import faker from 'faker'

describe('Member Membership', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders the membership page', () => {
    cy.visit('/membership')
    cy.contains('My membership my email', { matchCase: false })
  })
})
