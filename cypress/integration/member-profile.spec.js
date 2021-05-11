import faker from 'faker'

describe('Member Profile', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders the profile page', () => {
    cy.visit('/profile')
    cy.contains('My membership my email', { matchCase: false })
  })
})
