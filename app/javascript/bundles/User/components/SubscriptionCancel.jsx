import React, { useState } from 'react'
import Button from '@material-ui/core/Button'
import Dialog from '@material-ui/core/Dialog'
import DialogActions from '@material-ui/core/DialogActions'
import DialogContent from '@material-ui/core/DialogContent'
import DialogContentText from '@material-ui/core/DialogContentText'
import DialogTitle from '@material-ui/core/DialogTitle'

const SUBSCRIPTION_CANCEL_URL = userID => `/users/${userID}/subscription`

function SubscriptionCancelView ({ user, subscription }) {
  const [open, setOpen] = useState(false)
  const [active, toggleActive] = useState(subscription.active)

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
        method: 'delete'
      }
    )

    toggleActive(!subscription.active)

    handleClose()
  }

  if (!subscription.active) {
    return null
  }

  return (
    <div>
      <Button color='secondary' onClick={handleClickOpen}>
        Cancel Subscription
      </Button>
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
    </div>
  )
}

export const SubscriptionCancel = props => <SubscriptionCancelView {...props} />
