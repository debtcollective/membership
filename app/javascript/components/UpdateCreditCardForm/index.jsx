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
import Modal from '@material-ui/core/Modal'
// import { ReactComponent as close-button} from '../../../assets/icons/x-close.svg'

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
          className='input-green block w-full shadow-sm sm:text-sm focus:ring-lilac focus:border-lilac'
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
      className='btn-green inline-flex justify-center px-4 py-2 ml-3 text-sm font-bold text-white border border-transparent shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-lilac'
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
        'Update Card Info'
      )}
    </button>
  )
}

const CloseButton = ({ handleClose }) => {
  return (
    <svg
      onClick={handleClose}
      width='21'
      height='21'
      viewBox='0 0 21 21'
      fill='none'
      xmlns='http://www.w3.org/2000/svg'
    >
      <rect
        x='3.21069'
        width='24'
        height='4.54054'
        rx='2.27027'
        transform='rotate(45 3.21069 0)'
        fill='#434343'
      />
      <rect
        width='24'
        height='4.54054'
        rx='2.27027'
        transform='matrix(-0.707107 0.707107 0.707107 0.707107 16.9706 0)'
        fill='#434343'
      />
    </svg>
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

  const [open, setOpen] = React.useState(false)
  const handleOpen = () => {
    setOpen(true)
  }
  const handleClose = () => {
    setOpen(false)
  }

  return (
    <div className='update-cc-container w-full'>
      <button
        type='button'
        onClick={handleOpen}
        className='btn-green w-full inline-flex justify-center px-6 py-6 font-bold text-white shadow-sm hover:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-900 sm:ml-1.5'
      >
        Update Card Info
      </button>
      <Modal
        open={open}
        onClose={handleClose}
        aria-labelledby='update-cc-modal'
        aria-describedby='update-credit-card'
        disableScrollLock
        className='update-cc-modal flex justify-center sm:items-center relative sm:fixed overflow-y-auto'
      >
        <div className='modal-inner bg-white sm:w-4/5 py-6 xs:px-6 mb-10 sm:mb-4 flex flex-col absolute top-20'>
          <div className='close-button self-end mr-5 xs:mr-0'>
            <CloseButton handleClose={handleClose} />
          </div>
          <div className='mx-4 sm:mx-6'>
            <h3 className='font-black text-black text-3xl sm:text-4xl max-w-4xl'>
              Change Membership Card
            </h3>
            <p className='mt-2 font-thin text-gray-500 text-lg sm:text-2xl'>
              Update your card info.
            </p>
          </div>
          <form
            onSubmit={handleSubmit}
            className='space-y-4 mx-4 mb-10 sm:mb-4'
            action={action}
            method={method}
          >
            <input
              type='hidden'
              name='authenticity_token'
              value={authenticityToken}
            />

            <div className='grid grid-cols-1 mt-6 gap-y-2 gap-x-4 sm:grid-cols-6'>
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
                  className='input-green block w-full shadow-sm focus:ring-lilac focus:border-lilac sm:text-sm'
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
                  className='input-green block w-full rounded-md shadow-sm focus:ring-lilac focus:border-lilac sm:text-sm'
                />
              </div>

              <div className='sm:col-span-6'>
                <BillingAddressField countryOptions={countryOptions} />
              </div>

              <div className='sm:col-span-6'>
                <CreditCardField onChange={handleCardOnChange} />
              </div>
            </div>

            <div className=''>
              <div className='flex justify-end'>
                <SubmitButton isLoading={isLoading} />
              </div>
            </div>
          </form>
        </div>
      </Modal>
    </div>
  )
}

const stripePromise = loadStripe(window.App.STRIPE_PUBLISHABLE_KEY)

const FormWrapped = props => (
  <Elements stripe={stripePromise}>
    <UpdateCreditCardForm {...props} />
  </Elements>
)

export default FormWrapped
