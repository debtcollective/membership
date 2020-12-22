describe('Donation Spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders donation widget', () => {
    cy.visit('/test/donation_widget')
    cy.contains('Yay, you saved a compliment!')
  })
})
