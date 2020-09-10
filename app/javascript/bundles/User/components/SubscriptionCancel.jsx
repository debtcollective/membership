import React, { useState } from 'react'
import { makeStyles } from '@material-ui/core/styles'

import {
  Grid,
  Box,
  Typography,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  DialogTitle,
  Paper
} from '@material-ui/core'

const SUBSCRIPTION_CANCEL_URL = userID => `/users/${userID}/subscription`

const useStyles = makeStyles(theme => ({
  root: {
    height: '100%',
    marginTop: theme.spacing(3),
    overflowX: 'auto',
    padding: theme.spacing(4),
    width: '100%'
  },
  table: {
    minWidth: 650
  }
}))

const NoSubscriptionView = ({ user }) => {
  return (
    <Grid container direction='column' justify='center' alignItems='center'>
      <Box mb={2} textAlign='center'>
        <i className='material-icons md-48'>feedback</i>
        <Typography component='h2' variant='h5'>
          You don't have an active subscription
        </Typography>
      </Box>
      <Button href={`/`} variant='contained' color='primary'>
        Start a subscription
      </Button>
    </Grid>
  )
}

function SubscriptionCancelView ({
  user,
  subscription,
  currentPlan,
  isSubscriptionChanging
}) {
  const classes = useStyles()
  const isSubscriptionActive = subscription && subscription.active
  const [open, setOpen] = useState(false)
  const [active, toggleActive] = useState(isSubscriptionActive)

  const handleClickOpen = () => {
    setOpen(true)
  }

  const handleClose = () => {
    setOpen(false)
  }

  const handleSubscriptionCancellation = async () => {
    const isSubscriptionCancelled = await fetch(
      SUBSCRIPTION_CANCEL_URL(user.id),
      {
        method: 'delete',
        credentials: 'include',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json'
        }
      }
    )

    toggleActive(!isSubscriptionActive)

    handleClose()
  }

  if (!isSubscriptionActive) {
    return (
      <Paper className={classes.root}>
        <NoSubscriptionView user={user} />
      </Paper>
    )
  }

  return (
    <>
      <Paper className={classes.root}>
        <h3>You're subscribed</h3>
        <p>
          The plan you're using to contribute is{' '}
          <strong> {currentPlan.name}</strong>.
        </p>
        {!isSubscriptionChanging && (
          <Button
            component='a'
            href={`/users/${user.id}/plan_changes`}
            color='primary'
          >
            Change Subscription
          </Button>
        )}
        <Button color='secondary' onClick={handleClickOpen}>
          Cancel Subscription
        </Button>
      </Paper>
      {!active && 'No active subscription'}
      <Dialog
        open={open}
        onClose={handleClose}
        id='cancel-subscription-dialog'
        aria-labelledby='cancel-subscription-title'
        aria-describedby='cancel-subscription-description'
      >
        <DialogTitle id='cancel-subscription-title'>
          Do you want to terminate your current subscription?
        </DialogTitle>
        <DialogContent>
          <DialogContentText id='cancel-subscription-description'>
            Terminating your subscription will stop your current plan and the
            benefits you receive from it.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color='primary'>
            Close
          </Button>
          <Button
            onClick={handleSubscriptionCancellation}
            color='primary'
            autoFocus
          >
            Cancel Subscription
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export const SubscriptionCancel = props => <SubscriptionCancelView {...props} />
