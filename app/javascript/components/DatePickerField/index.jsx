import React, { useState } from 'react'
import DatePicker from 'react-date-picker/dist/entry.nostyle'
import moment from 'moment'

const DatePickerField = (props = {}) => {
  const { value, name } = props
  let initialValue

  if (value) {
    initialValue = moment(value).toDate()
  }

  const [date, setDate] = useState(initialValue)

  return (
    <>
      <DatePicker name={name} value={date} onChange={value => setDate(value)} />
    </>
  )
}

export default DatePickerField
