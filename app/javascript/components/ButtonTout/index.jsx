import React, { useState } from 'react'

const ButtonTout = (props = {}) => {
  const { title, text, link } = props

  return (
    <>
      <a href={link}>
        <h6>{title}</h6>
        <p>{text}</p>
      </a>
    </>
  )
}

export default ButtonTout
