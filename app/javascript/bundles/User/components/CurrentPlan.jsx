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

function CurrentPlanView ({ user, currentPlan, plans }) {
  const classes = useStyles()
  const [changedPlan, setPlanChanged] = useState(false)

  const changePlan = async selectedPlanId => {
    try {
      await fetch(CHANGE_PLAN_ENDPOINT(user.id), {
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
      setPlanChanged(true)
    } catch (error) {
      console.error(error) // TODO: Replace with sentry
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
      <h2>Available plans</h2>
      <p>You can change your current plan for another one at anytime.</p>
      {changedPlan && (
        <p className='notice--subscription'>
          We have changed your subscription successfully.
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
              disabled={currentPlan.id === plan.id || changedPlan}
              onClick={changeHandler}
            >
              Pick plan
            </Button>
          </Paper>
        )
      })}
    </>
  )
}

export const CurrentPlan = props => <CurrentPlanView {...props} />
