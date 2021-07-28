import React from 'react'
import PropTypes from 'prop-types'
import numeral from 'numeral'
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
    overflowX: 'auto',
  },
  table: {
    minWidth: 650,
  },
}))

export default function SubcriptionsTable ({ subscriptions }) {
  const classes = useStyles()

  return (
    <Paper className={classes.root}>
      <Table className={classes.table}>
        <TableHead>
          <TableRow>
            <TableCell>Name</TableCell>
            <TableCell>Email </TableCell>
            <TableCell>Amount</TableCell>
            <TableCell>Last Charged At</TableCell>
            <TableCell>Overdue?</TableCell>
            <TableCell>Beyond grace period?</TableCell>
            <TableCell />
          </TableRow>
        </TableHead>
        <TableBody>
          {subscriptions.map(subscription => {
            return (
              <TableRow key={subscription.id}>
                <TableCell scope='subscription'>
                  {subscription.user ? `${subscription.user.name}` : 'N/A'}
                </TableCell>
                <TableCell scope='subscription'>
                  {subscription.user ? `${subscription.user.email}` : 'N/A'}
                </TableCell>
                <TableCell>
                  {numeral(subscription.amount).format('$0,0.00')}
                </TableCell>
                <TableCell scope='subscription'>
                  {subscription.last_charge_at}
                </TableCell>
                <TableCell>{subscription['overdue?'].toString()}</TableCell>
                <TableCell>
                  {subscription['beyond_grace_period?'].toString()}
                </TableCell>
                <TableCell align='right'>
                  <a href={`/admin/subscriptions/${subscription.id}`}>Show</a>{' '}
                  <a href={`/admin/subscriptions/${subscription.id}/edit`}>
                    Edit
                  </a>{' '}
                  <a
                    data-confirm='Are you sure?'
                    rel='nofollow'
                    data-method='delete'
                    href={`/admin/subscriptions/${subscription.id}`}
                  >
                    Delete
                  </a>
                </TableCell>
              </TableRow>
            )
          })}
        </TableBody>
      </Table>
    </Paper>
  )
}

SubcriptionsTable.propTypes = {
  subscriptions: PropTypes.array,
}

SubcriptionsTable.defaultTypes = {
  subscriptions: [],
}
