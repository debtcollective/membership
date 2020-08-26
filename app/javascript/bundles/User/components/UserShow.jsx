import React from 'react'
import PropTypes from 'prop-types'
import { makeStyles } from '@material-ui/core/styles'
import Paper from '@material-ui/core/Paper'

const useStyles = makeStyles(theme => ({
  root: {
    width: '100%',
    marginTop: theme.spacing(3),
    padding: theme.spacing(4),
    overflowX: 'auto'
  }
}))

function UserShowView ({ user, subscription, streak }) {
  const classes = useStyles()
  const hasActiveSubscription = subscription && subscription.active

  return (
    <>
      {hasActiveSubscription && (
        <p className='notice--subscription'>
          You have been a member for {streak + 1} month{streak > 1 ? 's' : ''}
        </p>
      )}
      <Paper className={classes.root} id='contact-data'>
        <h3>Contact Data</h3>
        <p>
          <strong>Name:</strong>
        </p>
        <p>{user.name}</p>

        <p>
          <strong>Email:</strong>
        </p>
        <p>{user.email}</p>
      </Paper>
    </>
  )
}

UserShowView.propTypes = {
  user: PropTypes.object.isRequired,
  streak: PropTypes.number,
  subscription: PropTypes.object.isRequired
}

export const UserShow = props => <UserShowView {...props} />
