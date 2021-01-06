import React from 'react'
import ReactDOM from 'react-dom'
import { DonationWidget } from '@debtcollective/union-component'

window.addEventListener('load', () => {
  const element = React.createElement(DonationWidget, {}, null)
  const container = document.getElementById('app')

  ReactDOM.render(element, container)
})
