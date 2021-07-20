import React, { useState } from 'react'

const ButtonTout = (props = {}) => {
  const { title, text, link } = props

  return (
    <>
      <h6>{title}</h6>
      <p>{text}</p>
    </>
  )
}

export default ButtonTout
