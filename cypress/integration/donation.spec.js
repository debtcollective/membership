describe('Donation Spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders donation widget', () => {
    cy.visit('/test/widget/donation')
    cy.contains('DONATE', { matchCase: false })
  })

  it('makes a donation', () => {
    cy.visit('/test/widget/donation')

    // select amount
    cy.contains('$10').click()
    cy.get('button')
      .contains('DONATE', { matchCase: false })
      .click()

    // fill address
    cy.contains('PAYING 10$', { matchCase: false }).click()

    cy.get("input[name='address']").type('te amo')
    cy.get("input[name='city']").type('te amo')
    cy.get("input[name='zipCode']").type('te amo')
    cy.get("select[name='country']").select('MX')

    cy.get('button')
      .contains('NEXT STEP', { matchCase: false })
      .click()

    // complete card information
    cy.get("input[name='address']").type('te amo')
    cy.get("input[name='city']").type('te amo')

    // assert thank you screen
  })
})
