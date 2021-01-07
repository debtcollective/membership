// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

// Helpers to test Stripe elements fields.
// https://medium.com/@michabahr/testing-stripe-elements-with-cypress-5a2fc17ab27b
Cypress.Commands.add('iframeLoaded', { prevSubject: 'element' }, $iframe => {
  const contentWindow = $iframe.prop('contentWindow')

  return new Promise(resolve => {
    const document = contentWindow.document
    if (
      contentWindow &&
      document.readyState === 'complete' &&
      document.body.children.length > 0
    ) {
      resolve(contentWindow)
    } else {
      $iframe.on('load', () => {
        resolve(contentWindow)
      })
    }
  })
})

Cypress.Commands.add(
  'getInDocument',
  { prevSubject: 'document' },
  (document, selector) => Cypress.$(selector, document)
)

Cypress.Commands.add('getWithinIframe', targetElement =>
  cy
    .get('iframe')
    .iframeLoaded()
    .its('document')
    .getInDocument(targetElement)
)
