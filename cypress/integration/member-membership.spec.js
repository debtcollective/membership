import faker from 'faker'

describe('Member Membership', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders the membership page', () => {
    cy.appFactories([
      [
        'create',
        'user_with_subscription',
        { email: 'example@debtcollective.org' },
      ],
    ]).then(async records => {
      const [user] = records
      cy.forceLogin({ email: user.email }).then(result => {
        cy.visit('/membership')
        cy.contains('Membership', { matchCase: false })
      })
    })
  })

  describe('Update amount', () => {
    describe('with payment method', () => {
      it('updates the amount', () => {
        cy.appFactories([
          [
            'create',
            'user_with_subscription_and_stripe',
            { email: 'example@debtcollective.org' },
          ],
        ]).then(async records => {
          const [user] = records
          cy.forceLogin({ email: user.email }).then(result => {
            cy.visit('/membership')
            cy.get('a')
              .contains('Change amount', { matchCase: false })
              .click()

            // Name
            cy.get("input[name='membership[amount]']")
              .clear()
              .type(10)

            // Submit
            cy.get('input')
              .contains('Save', { matchCase: false })
              .click()

            cy.contains('Amount changed')
          })
        })
      })
      describe('without payment method', () => {
        it('updates the amount if amount is set to zero', () => {
          cy.appFactories([
            [
              'create',
              'user_with_subscription',
              { email: 'example@debtcollective.org' },
            ],
          ]).then(async records => {
            const [user] = records
            cy.forceLogin({ email: user.email }).then(result => {
              cy.visit('/membership')
              cy.get('a')
                .contains('Change amount', { matchCase: false })
                .click()

              // Name
              cy.get("input[name='membership[amount]']")
                .clear()
                .type(0)

              // Submit
              cy.get('input')
                .contains('Save', { matchCase: false })
                .click()

              cy.contains('Amount changed')
            })
          })
        })

        it('returns an error if amount is greater than five', () => {
          cy.appFactories([
            [
              'create',
              'user_with_subscription',
              { email: 'example@debtcollective.org' },
            ],
          ]).then(async records => {
            const [user] = records
            cy.forceLogin({ email: user.email }).then(result => {
              cy.visit('/membership')
              cy.get('a')
                .contains('Change amount', { matchCase: false })
                .click()

              // Name
              cy.get("input[name='membership[amount]']")
                .clear()
                .type(5)

              // Submit
              cy.get('input')
                .contains('Save', { matchCase: false })
                .click()

              cy.contains('You need to add a credit card first')
            })
          })
        })
      })
    })
  })

  describe('Update payment', () => {
    it('updates the payment method', () => {
      cy.appFactories([
        [
          'create',
          'user_with_subscription_and_stripe',
          { email: 'example@debtcollective.org' },
        ],
      ]).then(async records => {
        const [user] = records
        cy.forceLogin({ email: user.email }).then(result => {
          cy.visit('/membership')
          cy.get('a')
            .contains('Update credit card', { matchCase: false })
            .click()

          // Name
          cy.get("input[name='membership[first_name]']").type(
            faker.name.firstName()
          )
          cy.get("input[name='membership[last_name]']").type(
            faker.name.lastName()
          )

          // Address
          cy.get("input[name='membership[address_line1]']").type(
            faker.address.streetAddress()
          )
          cy.get("input[name='membership[address_city]']").type(
            faker.address.city()
          )
          cy.get("input[name='membership[address_state]']").type(
            faker.address.state()
          )
          cy.get("input[name='membership[address_zip]']").type(
            faker.address.zipCode()
          )
          cy.get("select[name='membership[address_country_code]']").select(
            'United States'
          )

          // Credit card
          cy.getWithinIframe('[name="cardnumber"]').type('4242424242424242')
          cy.getWithinIframe('[name="exp-date"]').type('1232')
          cy.getWithinIframe('[name="cvc"]').type('987')
          cy.getWithinIframe('[name="postal"]').type('12345')

          // Submit
          cy.get('button')
            .contains('Save', { matchCase: false })
            .click()

          cy.contains(
            'Your credit card was updated, and it will be effective on your next billing'
          )
          cy.contains('Card ending in 4242')
        })
      })
    })

    describe('with a pending payment', () => {
      it('updates the payment method and marks subscription as active', () => {
        cy.appFactories([
          [
            'create',
            'user_with_overdue_subscription',
            { email: 'example@debtcollective.org' },
          ],
        ]).then(async records => {
          const [user] = records
          cy.forceLogin({ email: user.email }).then(result => {
            cy.visit('/membership')
            cy.get('a')
              .contains('Update credit card', { matchCase: false })
              .click()

            // Name
            cy.get("input[name='membership[first_name]']").type(
              faker.name.firstName()
            )
            cy.get("input[name='membership[last_name]']").type(
              faker.name.lastName()
            )

            // Address
            cy.get("input[name='membership[address_line1]']").type(
              faker.address.streetAddress()
            )
            cy.get("input[name='membership[address_city]']").type(
              faker.address.city()
            )
            cy.get("input[name='membership[address_state]']").type(
              faker.address.state()
            )
            cy.get("input[name='membership[address_zip]']").type(
              faker.address.zipCode()
            )
            cy.get("select[name='membership[address_country_code]']").select(
              'United States'
            )

            // Credit card
            cy.getWithinIframe('[name="cardnumber"]').type('4242424242424242')
            cy.getWithinIframe('[name="exp-date"]').type('1232')
            cy.getWithinIframe('[name="cvc"]').type('987')
            cy.getWithinIframe('[name="postal"]').type('12345')

            // Submit
            cy.get('button')
              .contains('Save', { matchCase: false })
              .click()

            cy.contains(
              'Your credit card was updated, and your payment was done correctly'
            )
            cy.contains('Card ending in 4242')
          })
        })
      })
    })
  })

  describe('Pause membership', () => {
    it('pauses the membership', () => {
      cy.appFactories([
        [
          'create',
          'user_with_subscription',
          { email: 'example@debtcollective.org' },
        ],
      ]).then(async records => {
        const [user] = records
        cy.forceLogin({ email: user.email }).then(result => {
          cy.visit('/membership')

          cy.get('input[type="submit"][value="Pause subscription"]').click()

          cy.contains('Your membership is now paused')
        })
      })
    })
  })

  describe('Resume membership', () => {
    it('activates the membership', () => {
      cy.appFactories([
        [
          'create',
          'user_with_subscription',
          {
            email: 'example@debtcollective.org',
            subscription_status: 'paused',
          },
        ],
      ]).then(async records => {
        const [user] = records
        cy.forceLogin({ email: user.email }).then(result => {
          cy.visit('/membership')

          cy.get('input[type="submit"][value="Resume subscription"]').click()

          cy.contains('Your membership is now active')
        })
      })
    })
  })
})
