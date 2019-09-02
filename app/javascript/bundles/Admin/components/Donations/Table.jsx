import React from 'react'
import PropTypes from 'prop-types'
import numeral from 'numeral'
import moment from 'moment'
import { makeStyles } from '@material-ui/core/styles'
import Table from '@material-ui/core/Table'
import TableBody from '@material-ui/core/TableBody'
import TableCell from '@material-ui/core/TableCell'
import TableHead from '@material-ui/core/TableHead'
import TableRow from '@material-ui/core/TableRow'
import Paper from '@material-ui/core/Paper'

const useStyles = makeStyles(theme => ({
  root: {
    width: '100%',
    marginTop: theme.spacing(3),
    overflowX: 'auto'
  },
  table: {
    minWidth: 650
  }
}))

const DONATION_TYPES = {
  ONE_OFF: 'One time Donation',
  SUBSCRIPTION: 'Monthly Subscription'
}

export default function DonationsTable ({ donations }) {
  const classes = useStyles()

  return (
    <Paper className={classes.root}>
      <Table className={classes.table}>
        <TableHead>
          <TableRow>
            <TableCell>Status</TableCell>
            <TableCell>Customer Stripe ID</TableCell>
            <TableCell>Type</TableCell>
            <TableCell>Donated at</TableCell>
            <TableCell>Amount</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {donations.map(donation => (
            <TableRow key={donation.id} id={`donation-${donation.id}`}>
              <TableCell scope='donation' className='capitalized'>
                {donation.status}
              </TableCell>
              <TableCell>{donation.customer_stripe_id}</TableCell>
              <TableCell>
                {DONATION_TYPES[donation.donation_type] || 'Other'}
              </TableCell>
              <TableCell>
                {moment(donation.created_at).format('MMMM Do YYYY, h:mm:ss a')}
              </TableCell>
              <TableCell>
                {numeral(donation.amount).format('$0,0.00')}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </Paper>
  )
}

DonationsTable.propTypes = {
  donations: PropTypes.array
}

DonationsTable.defaultTypes = {
  donations: []
}
