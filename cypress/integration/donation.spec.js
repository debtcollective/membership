import faker from 'faker'

describe('Donation Spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders donation widget', () => {
    cy.visit('/test/widget/donation')
    cy.contains('DONATE', { matchCase: false })
  })

  it('makes a donation', () => {
    cy.appFactories([
      ['create', 'fund', { name: 'Betsy DeVos retirement fund' }]
    ]).then(records => {
      const fund = records[0]
      cy.visit('/test/widget/donation')

      // select amount
      cy.contains('$10').click()
      cy.get('button')
        .contains('DONATE', { matchCase: false })
        .click()

      // fill address
      cy.contains('PAYING $10', { matchCase: false }).click()

      const zipCode = faker.address.zipCode()
      cy.get("input[name='address']").type(faker.address.streetAddress())
      cy.get("input[name='city']").type(faker.address.city())
      cy.get("input[name='zipCode']").type(zipCode)
      cy.get("select[name='country']").select(faker.address.countryCode())

      cy.get('button')
        .contains('NEXT STEP', { matchCase: false })
        .click()

      // complete payment information
      cy.get("select[name='fund']").select(fund.name)
      cy.get("input[name='firstName']").type(faker.name.firstName())
      cy.get("input[name='lastName']").type(faker.name.lastName())
      cy.get("input[name='email']").type(faker.internet.email())
      cy.get("input[name='phoneNumber']").type(
        faker.phone.phoneNumber('### ### ####')
      )

      cy.getWithinIframe('[name="cardnumber"]').type('4242424242424242')
      cy.getWithinIframe('[name="exp-date"]').type('1232')
      cy.getWithinIframe('[name="cvc"]').type('987')
      cy.getWithinIframe('[name="postal"]').type('12345')

      cy.get('button')
        .contains('NEXT STEP', { matchCase: false })
        .click()

      // assert thank you screen
      cy.contains('Your $10.00 donation has been successfully processed.')
    })
  })
})
