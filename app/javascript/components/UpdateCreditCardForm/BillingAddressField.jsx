import React from 'react'

const BillingAddressField = ({ countryOptions = [] }) => {
  return (
    <fieldset className='mt-2 bg-white'>
      <legend className='block text-sm font-medium text-gray-700'>
        Address
      </legend>
      <div className='mt-1 -space-y-px rounded-md shadow-sm'>
        <div>
          <label htmlFor='address_line_1' className='sr-only'>
            Street
          </label>
          <input
            type='text'
            name='address_line_1'
            id='address_line_1'
            placeholder='Street'
            className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-indigo-500 focus:border-indigo-500 rounded-t-md focus:z-10 sm:text-sm'
          />
        </div>
        <div>
          <label htmlFor='address_city' className='sr-only'>
            City
          </label>
          <input
            type='text'
            name='address_city'
            id='address_city'
            placeholder='City'
            className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm'
          />
        </div>
        <div className='flex'>
          <div className='w-full'>
            <label htmlFor='address_state' className='sr-only'>
              State
            </label>
            <input
              type='text'
              name='address_state'
              id='address_state'
              placeholder='State'
              className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm'
            />
          </div>
          <div className='w-full'>
            <label htmlFor='address_zip' className='sr-only'>
              Zip code
            </label>
            <input
              type='text'
              name='address_zip'
              id='address_zip'
              placeholder='Zip code'
              className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm'
            />
          </div>
        </div>
        <div>
          <select
            name='address_country_code'
            className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-indigo-500 focus:border-indigo-500 rounded-b-md focus:z-10 sm:text-sm'
          >
            <option selected disabled hidden>
              Select Country
            </option>
            {countryOptions.map(country => {
              return (
                <option value={country[1]} key={country[1]}>
                  {country[0]}
                </option>
              )
            })}
          </select>
        </div>
      </div>
    </fieldset>
  )
}

export default BillingAddressField
