import React from 'react'

const BillingAddressField = ({ countryOptions = [] }) => {
  return (
    <fieldset className='mt-2 bg-white'>
      <legend className='block text-sm font-medium text-gray-700'>
        Address
      </legend>
      <div className='mt-1 rounded-md shadow-sm'>
        <div className='my-4'>
          <label htmlFor='address_line1' className='sr-only'>
            Street
          </label>
          <input
            type='text'
            name='membership[address_line1]'
            id='address_line1'
            placeholder='Street'
            className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-lilac focus:border-lilac rounded-t-md focus:z-10 sm:text-sm'
            required
          />
        </div>
        <div className='my-4'>
          <label htmlFor='address_city' className='sr-only'>
            City
          </label>
          <input
            type='text'
            name='membership[address_city]'
            id='address_city'
            placeholder='City'
            className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-lilac focus:border-lilac focus:z-10 sm:text-sm'
            required
          />
        </div>
        <div className='flex my-4'>
          <div className='w-full mr-2'>
            <label htmlFor='address_state' className='sr-only'>
              State
            </label>
            <input
              type='text'
              name='membership[address_state]'
              id='address_state'
              placeholder='State'
              className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-lilac focus:border-lilac focus:z-10 sm:text-sm'
              required
            />
          </div>
          <div className='w-full ml-2'>
            <label htmlFor='address_zip' className='sr-only'>
              Zip code
            </label>
            <input
              type='text'
              name='membership[address_zip]'
              id='address_zip'
              placeholder='Zip code'
              className='relative block w-full bg-transparent border-l-0 border-gray-300 rounded-none focus:ring-lilac focus:border-lilac focus:z-10 sm:text-sm'
              required
            />
          </div>
        </div>
        <div>
          <select
            name='membership[address_country_code]'
            defaultValue=''
            className='relative block w-full bg-transparent border-gray-300 rounded-none focus:ring-lilac focus:border-lilac rounded-b-md focus:z-10 sm:text-sm'
            required
          >
            <option value='' disabled hidden>
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
