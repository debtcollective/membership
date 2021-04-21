import React, { useState } from 'react'
import DatePicker from 'react-date-picker'

const DatePickerField = (props = {}) => {
  const { value, name } = props
  const [date, setDate] = useState(new Date())

  return (
    <>
      <DatePicker value={date} onChange={value => setDate(value)} />
      <input name={name} type='hidden' value={date} />
    </>
  )
}

export default DatePickerField
