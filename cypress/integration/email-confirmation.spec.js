import faker from 'faker'

describe('Membership Spec', () => {
  beforeEach(() => {
    cy.request('/cypress_rails_reset_state')
  })

  describe('happy', () => {
    it('renders the confirmation page and user confirms its email address', () => {
      cy.appFactories([['create', 'user_with_email_token', {}]]).then(
        records => {
          const user = records[0]
          const redirectUrl = `http://lvh.me:3000/session/email-login/${user.email_token}`
          cy.visit(`/user_confirmations/confirm_email/${user.email_token}`)

          // assert the redirect
          cy.intercept(redirectUrl, req => {
            expect(req.url).to.eq(redirectUrl)
            req.reply({ status: 200, body: `redirected to ${redirectUrl}` })
          })

          cy.contains('Confirm my email', { matchCase: false }).click()
        }
      )
    })
  })
})
