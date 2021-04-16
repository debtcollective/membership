import React from 'react'
import PhoneInput from 'react-phone-number-input'

const PhoneNumberField = (props = {}) => {
  // server-side rendering
  if (typeof window === 'undefined') {
    return null
  }

  return (
    <PhoneInput
      onChange={val => {
        console.log(val)
      }}
      {...props}
    />
  )
}

export default PhoneNumberField
