// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require('turbolinks').start()
require('alpinejs')

import 'stylesheets/application'

document.addEventListener('DOMContentLoaded', function (event) {
  const alertsClose = document.querySelectorAll('.alert button.alert-close')

  alertsClose.forEach(function (node) {
    node.addEventListener('click', function () {
      this.closest('.alert').remove()
    })
  })
})

// Support component names relative to this directory:
var componentRequireContext = require.context('components', true)
var ReactRailsUJS = require('react_ujs')
ReactRailsUJS.useContext(componentRequireContext)
