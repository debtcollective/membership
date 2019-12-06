import React from 'react'
import PropTypes from 'prop-types'
import { makeStyles } from '@material-ui/core/styles'
import Paper from '@material-ui/core/Paper'

const useStyles = makeStyles(theme => ({
  root: {
    marginTop: theme.spacing(1),
    marginBottom: theme.spacing(1),
    marginLeft: theme.spacing(2),
    marginRight: theme.spacing(2),
    padding: theme.spacing(2),
    flex: 1,
    textAlign: 'center'
  },
  text: {
    fontSize: '3rem'
  },
  description: {
    fontSize: '1rem'
  }
}))

export const Metric = ({ description, text }) => {
  const classes = useStyles()

  return (
    <Paper className={classes.root}>
      <h2 className={classes.text}>{text}</h2>
      <p className={classes.description}>{description}</p>
    </Paper>
  )
}

Metric.propTypes = {
  description: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired
}
