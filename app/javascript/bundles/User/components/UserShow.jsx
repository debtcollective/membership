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

  return (
    <Paper className={classes.root}>
      {subscription && streak && <p>You have been subscribed for {streak}</p>}
      <p>
        <strong>First name:</strong>
      </p>
      <p>{user.first_name}</p>

      <p>
        <strong>Last name:</strong>
      </p>
      <p>{user.last_name}</p>

      <p>
        <strong>Email:</strong>
      </p>
      <p>{user.email}</p>

      <p>
        <strong>User role:</strong>
      </p>
      <p>{user.user_role}</p>

      <p>
        <strong>Discourse:</strong>
      </p>
      <p>{user.discourse_id}</p>
    </Paper>
  )
}

UserShowView.propTypes = {
  user: PropTypes.object.isRequired,
  streak: PropTypes.string,
  subscription: PropTypes.object.isRequired
}

export const UserShow = props => <UserShowView {...props} />
