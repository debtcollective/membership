import React from 'react'
import ReactDOM from 'react-dom'
import { MembershipWidget } from '@debtcollective/union-component'

window.addEventListener('load', () => {
  const element = React.createElement(MembershipWidget, {}, null)
  const container = document.getElementById('app')

  ReactDOM.render(element, container)
})
