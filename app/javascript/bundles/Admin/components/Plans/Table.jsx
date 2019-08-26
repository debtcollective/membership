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
    overflowX: 'auto'
  },
  table: {
    minWidth: 650
  }
}))

export default function PlansTable ({ plans }) {
  const classes = useStyles()
  // <td><%= plan.name %></td>
  //       <td><%= plan.description %></td>
  //   <td>$<%= plan.amount %></td>

  return (
    <Paper className={classes.root}>
      <Table className={classes.table}>
        <TableHead>
          <TableRow>
            <TableCell>Name</TableCell>
            <TableCell>Description</TableCell>
            <TableCell>Amount</TableCell>
            <TableCell />
          </TableRow>
        </TableHead>
        <TableBody>
          {plans.map(plan => (
            <TableRow key={plan.id}>
              <TableCell component='th' scope='plan'>
                {plan.name}
              </TableCell>
              <TableCell>{plan.description}</TableCell>
              <TableCell>{numeral(plan.amount).format('$0,0.00')}</TableCell>
              <TableCell align='right'>
                <a href={`/admin/plans/${plan.id}`}>Show</a>{' '}
                <a href={`/admin/plans/${plan.id}/edit`}>Edit</a>{' '}
                <a
                  data-confirm='Are you sure?'
                  rel='nofollow'
                  data-method='delete'
                  href={`/plans/${plan.id}`}
                >
                  Delete
                </a>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </Paper>
  )
}

PlansTable.propTypes = {
  plans: PropTypes.array
}

PlansTable.defaultTypes = {
  plans: []
}
