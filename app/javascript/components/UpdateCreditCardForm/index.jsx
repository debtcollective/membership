// instead of having a field, I think to keep it sane I'll have to implement
// the whole form as a React component?

import React, { useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'
import {
  CardElement,
  Elements,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js'
import BillingAddressField from './BillingAddressField'

const CreditCardField = ({ onChange }) => {
  const stripe = useStripe()
  const elements = useElements()

  return (
    <>
      <label
        htmlFor='stripe-elements'
        className='block text-sm font-medium text-gray-700'
      >
        Credit Card
      </label>
      <div className='mt-1'>
        <CardElement
          id='stripe-elements'
          className='block w-full border-gray-300 rounded-md shadow-sm sm:text-sm focus:ring-lilac focus:border-lilac'
          onChange={onChange}
        />
      </div>
    </>
  )
}

const SubmitButton = ({ isLoading }) => {
  return (
    <button
      disabled={isLoading}
      className='submit-btn inline-flex justify-center px-4 py-2 ml-3 text-sm font-medium text-white bg-lilac border border-transparent rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-lilac'
    >
      {isLoading ? (
        <>
          <svg
            className='w-5 h-5 mr-3 -ml-1 text-white animate-spin'
            xmlns='http://www.w3.org/2000/svg'
            fill='none'
            viewBox='0 0 24 24'
            width='1em'
            height='1em'
          >
            <circle
              className='opacity-25'
              cx={12}
              cy={12}
              r={10}
              stroke='currentColor'
              strokeWidth={4}
            />
            <path
              className='opacity-75'
              fill='currentColor'
              d='M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z'
            />
          </svg>
          Saving
        </>
      ) : (
        'Save'
      )}
    </button>
  )
}

const UpdateCreditCardForm = ({
  action,
  method,
  authenticityToken,
  countryOptions,
}) => {
  const stripe = useStripe()
  const elements = useElements()
  const [isLoading, setIsLoading] = useState(false)

  const handleCardOnChange = event => {
    // TODO: make sure we disable the input in case of card error
  }

  const handleSubmit = async event => {
    const formData = new FormData(event.target)
    event.preventDefault()

    setIsLoading(true)

    const billingInformation = {
      name: `${formData.get('membership[first_name]')} ${formData.get(
        'membership[last_name]'
      )}`,
      address_line1: formData.get('membership[address_line1]'),
      address_city: formData.get('membership[address_city]'),
      address_zip: formData.get('membership[address_zip]'),
      address_state: formData.get('membership[address_state]'),
      address_country: formData.get('membership[address_country_code]'),
    }

    // tokenize card and billing information
    try {
      const { token } = await stripe.createToken(
        elements.getElement(CardElement),
        billingInformation
      )

      formData.set('membership[stripe_token]', token.id)
      formData.set('membership[stripe_card_id]', token.card.id)
      formData.set('membership[stripe_card_last4]', token.card.last4)
    } catch (e) {
      console.log(e)
      return
    }

    try {
      const response = await fetch('/membership/update_card', {
        method: method,
        body: formData,
      })

      const json = await response.json()
      window.location.href = json['redirect_to']
    } catch (e) {
      console.log(e)
      return
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className='space-y-8'
      action={action}
      method={method}
    >
      <input
        type='hidden'
        name='authenticity_token'
        value={authenticityToken}
      />

      <div className='grid grid-cols-1 mt-6 gap-y-4 gap-x-4 sm:grid-cols-6'>
        <div className='sm:col-span-3'>
          <label
            htmlFor='stripe-elements'
            className='block text-sm font-medium text-gray-700'
          >
            First name
          </label>
          <input
            type='text'
            name='membership[first_name]'
            className='block w-full border-gray-300 rounded-md shadow-sm focus:ring-lilac focus:border-lilac sm:text-sm'
            required
          />
        </div>

        <div className='sm:col-span-3'>
          <label
            htmlFor='stripe-elements'
            className='block text-sm font-medium text-gray-700'
          >
            Last name
          </label>
          <input
            type='text'
            name='membership[last_name]'
            required
            className='block w-full border-gray-300 rounded-md shadow-sm focus:ring-lilac focus:border-lilac sm:text-sm'
          />
        </div>

        <div className='sm:col-span-6'>
          <BillingAddressField countryOptions={countryOptions} />
        </div>

        <div className='sm:col-span-6'>
          <CreditCardField onChange={handleCardOnChange} />
        </div>
      </div>

      <div className='pt-5'>
        <div className='flex justify-end'>
          <SubmitButton isLoading={isLoading} />
        </div>
      </div>
    </form>
  )
}

const stripePromise = loadStripe(window.App.STRIPE_PUBLISHABLE_KEY)

const FormWrapped = props => (
  <Elements stripe={stripePromise}>
    <UpdateCreditCardForm {...props} />
  </Elements>
)

export default FormWrapped
