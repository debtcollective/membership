describe('Donation Spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders donation widget', () => {
    cy.visit('/test/widget/donation')
    cy.contains('Yay, you saved a compliment!')
  })
})
