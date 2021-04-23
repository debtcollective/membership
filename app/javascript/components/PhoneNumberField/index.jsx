import React, { useState } from 'react'
import PhoneInput from 'react-phone-number-input'

const PhoneNumberField = (props = {}) => {
  // server-side rendering
  if (typeof window === 'undefined') {
    return null
  }

  const { value, name, className } = props
  const [phoneNumber, setPhoneNumber] = useState(value)

  return (
    <>
      <PhoneInput
        defaultCountry='US'
        international={false}
        className={className}
        onChange={value => setPhoneNumber(value || '')}
        value={phoneNumber}
        smartCaret={false}
        withCountryCallingCode={false}
      />
      <input name={name} type='hidden' value={phoneNumber} />
    </>
  )
}

export default PhoneNumberField
