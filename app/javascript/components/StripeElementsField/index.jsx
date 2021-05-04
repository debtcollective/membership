import React from 'react'
import { loadStripe } from '@stripe/stripe-js'
import {
  CardElement,
  Elements,
  useStripe,
  useElements
} from '@stripe/react-stripe-js'

const CreditCardField = () => {
  const stripe = useStripe()
  const elements = useElements()

  const handleSubmit = async event => {
    event.preventDefault()
    const { error, paymentMethod } = await stripe.createPaymentMethod({
      type: 'card',
      card: elements.getElement(CardElement)
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <CardElement />
    </form>
  )
}

const stripePromise = loadStripe('pk_test_6pRNASCoBOKtIshFeQd4XMUh')

export default () => (
  <Elements stripe={stripePromise}>
    <CreditCardField />
  </Elements>
)
