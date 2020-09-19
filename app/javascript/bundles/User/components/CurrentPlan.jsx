import React, { useState } from 'react'
import numeral from 'numeral'
import { makeStyles } from '@material-ui/core/styles'
import Button from '@material-ui/core/Button'
import Paper from '@material-ui/core/Paper'

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

const CHANGE_PLAN_ENDPOINT = id => `/users/${id}/plan_changes`

function CurrentPlanView ({ user, currentPlan, pendingPlanChange, plans }) {
  const classes = useStyles()
  const [planChange, setPlanChange] = useState(pendingPlanChange)
  const pendingPlanChangePlan =
    planChange && plans.find(plan => plan.id == planChange.new_plan_id)

  const changePlan = async selectedPlanId => {
    try {
      const response = await fetch(CHANGE_PLAN_ENDPOINT(user.id), {
        body: JSON.stringify({
          plan_change: {
            old_plan_id: currentPlan.id,
            new_plan_id: selectedPlanId
          }
        }),
        credentials: 'include',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json'
        },
        method: 'post'
      })

      const json = await response.json()
      setPlanChange(json)
    } catch (error) {
      console.error(error)
      Sentry.captureException(error)
    }
  }

  return (
    <>
      <Paper className={classes.root}>
        <h3>Change your susbcription</h3>
        <p>
          Your membership tier is <strong>{currentPlan.name}</strong>.
        </p>
      </Paper>
      <br />
      <h2>Available tiers</h2>
      <p>You can change your membership tier to another one at anytime.</p>
      {planChange && (
        <p className='notice--subscription'>
          Your plan is scheduled to change to{' '}
          <strong>{pendingPlanChangePlan.name}</strong>. The new amount will be
          charged on your next billing cycle.
        </p>
      )}
      {plans.map(plan => {
        function createMarkup () {
          return { __html: plan.description.body }
        }

        function changeHandler () {
          return changePlan(plan.id)
        }

        return (
          <Paper className={classes.root} key={plan.id} id={`plan-${plan.id}`}>
            <h4>{plan.name}</h4>
            <p>Price: {numeral(plan.amount).format('$0,0.00')}</p>
            <p dangerouslySetInnerHTML={createMarkup()} />
            <Button
              variant='contained'
              color='primary'
              disabled={currentPlan.id === plan.id || !!planChange}
              onClick={changeHandler}
            >
              Select this tier
            </Button>
          </Paper>
        )
      })}
    </>
  )
}

export const CurrentPlan = props => <CurrentPlanView {...props} />