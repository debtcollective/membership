import React from 'react'
import PropTypes from 'prop-types'
import numeral from 'numeral'
import { makeStyles } from '@material-ui/core/styles'
import { Metric } from './Metric'

const useStyles = makeStyles(theme => ({
  root: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    flexWrap: 'wrap',
  },
}))

const transformToMoneyFormat = number => numeral(number).format('$0,0.00')

const DashboardView = ({
  activeSubsctiptions,
  amountFromSubscriptions,
  donationsCount,
  amountFromDonations,
}) => {
  const classes = useStyles()

  return (
    <React.Fragment>
      <div className={classes.root}>
        <Metric
          text={activeSubsctiptions}
          description={'Number of active subscriptions'}
        />
        <Metric
          text={transformToMoneyFormat(amountFromSubscriptions)}
          description={'Donated from subscriptions'}
        />
        <Metric
          text={donationsCount}
          description={'Number of one time donations'}
        />
        <Metric
          text={transformToMoneyFormat(amountFromDonations)}
          description={'Donated from one time donations'}
        />
      </div>
      <small>All metrics shown start from the beginning of time.</small>
    </React.Fragment>
  )
}

DashboardView.propTypes = {
  activeSubsctiptions: PropTypes.number.isRequired,
  amountFromSubscriptions: PropTypes.number.isRequired,
  donationsCount: PropTypes.number.isRequired,
  amountFromDonations: PropTypes.number.isRequired,
}

export const Dashboard = props => <DashboardView {...props} />
