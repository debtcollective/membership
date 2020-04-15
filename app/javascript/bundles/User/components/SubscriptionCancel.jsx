import React, { useState } from 'react'
import { makeStyles } from '@material-ui/core/styles'
import Button from '@material-ui/core/Button'
import Dialog from '@material-ui/core/Dialog'
import DialogActions from '@material-ui/core/DialogActions'
import DialogContent from '@material-ui/core/DialogContent'
import DialogContentText from '@material-ui/core/DialogContentText'
import DialogTitle from '@material-ui/core/DialogTitle'
import Paper from '@material-ui/core/Paper'

const SUBSCRIPTION_CANCEL_URL = userID => `/users/${userID}/subscription`

const useStyles = makeStyles(theme => ({
  root: {
    width: '100%',
    marginTop: theme.spacing(3),
    padding: theme.spacing(4),
    overflowX: 'auto'
  },
  table: {
    minWidth: 650
  }
}))

const NoSubscriptionView = ({}) => (
  <div>
    <p>no sub</p>
  </div>
)

function SubscriptionCancelView ({
  user,
  subscription,
  activePlan,
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
    return <NoSubscriptionView />
  }

  return (
    <>
      <Paper className={classes.root}>
        <h3>You're subscribed</h3>
        <p>
          The plan you're using to contribute is{' '}
          <strong> {activePlan.name}</strong>.
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
