// instead of having a field, I think to keep it sane I'll have to implement
// the whole form as a React component?

import React from 'react'
import { loadStripe } from '@stripe/stripe-js'
import {
  CardElement,
  Elements,
  useStripe,
  useElements
} from '@stripe/react-stripe-js'

const stripePromise = loadStripe('pk_test_TYooMQauvdEDq54NiTphI7jx')

const BillingAddressField = () => {
  return (
    <fieldset className='mt-2 bg-white'>
      <legend className='block text-sm font-medium text-gray-700'>
        Address
      </legend>
      <div className='mt-1 -space-y-px rounded-md shadow-sm'>
        <div>
          {/* <%= f.label :address_line1, class: "sr-only" %>
          <%= f.text_field :address_line1, class: "focus:ring-indigo-500 focus:border-indigo-500 relative block w-full rounded-none rounded-t-md bg-transparent focus:z-10 sm:text-sm border-gray-300", placeholder: "Street" %> */}
        </div>
        <div>
          {/* <%= f.label :address_city, class: "sr-only" %>
          <%= f.text_field :address_city, class: "focus:ring-indigo-500 focus:border-indigo-500 relative block w-full rounded-none bg-transparent focus:z-10 sm:text-sm border-gray-300", placeholder: "City" %> */}
        </div>
        <div className='flex'>
          <div className='w-full'>
            {/* <%= f.label :address_state, class: "sr-only" %>
            <%= f.text_field :address_state, class: "focus:ring-indigo-500 focus:border-indigo-500 relative block w-full rounded-none bg-transparent focus:z-10 sm:text-sm border-gray-300", placeholder: "State" %> */}
          </div>
          <div className='w-full'>
            {/* <%= f.label :address_zip, class: "sr-only" %>
            <%= f.text_field :address_zip, class: "focus:ring-indigo-500 focus:border-indigo-500 relative block w-full rounded-none bg-transparent focus:z-10 sm:text-sm border-gray-300 border-l-0", placeholder: "Postal code" %> */}
          </div>
        </div>
        <div>
          {/* <%= f.label :address_country_code, class: "sr-only" %>
          <%= f.country_select(:address_country_code, {priority_countries: ['US', 'CA'], include_blank: "Select country"}, {class: 'focus:ring-indigo-500 focus:border-indigo-500 relative block w-full rounded-none rounded-b-md bg-transparent focus:z-10 sm:text-sm border-gray-300', id: 'address-country-code-select', required: true}) %> */}
        </div>
      </div>
    </fieldset>
  )
}

const CreditCardField = () => {
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
          className='block w-full border-gray-300 rounded-md shadow-sm sm:text-sm focus:ring-indigo-500 focus:border-indigo-500'
        />
      </div>
    </>
  )
}

const UpdateCreditCardForm = ({ action, method, authenticityToken }) => {
  const stripe = useStripe()
  const elements = useElements()

  const handleSubmit = async event => {
    event.preventDefault()
    debugger
    const { error, paymentMethod } = await stripe.createPaymentMethod({
      type: 'card',
      card: elements.getElement(CardElement)
    })
  }

  return (
    <Elements stripe={stripePromise}>
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
              name='first_name'
              className='block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm'
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
              name='last_name'
              className='block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm'
            />
          </div>

          <div className='sm:col-span-6'>
            <CreditCardField />
          </div>
        </div>

        <div className='pt-5'>
          <div className='flex justify-end'>
            <button className='inline-flex justify-center px-4 py-2 ml-3 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500'>
              Save
            </button>
          </div>
        </div>
      </form>
    </Elements>
  )
}

const FormWrapped = props => (
  <Elements stripe={stripePromise}>
    <UpdateCreditCardForm {...props} />
  </Elements>
)

export default FormWrapped
