import faker from 'faker'

describe('Member Profile', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  it('renders the profile page', () => {
    cy.appFactories([
      ['create', 'user', { email: 'example@debtcollective.org' }]
    ]).then(async records => {
      const [user] = records
      cy.forceLogin({ email: user.email }).then(result => {
        cy.visit('/profile')
      })
    })
  })
})
