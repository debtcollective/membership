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

export default function FundsTable ({ funds }) {
  const classes = useStyles()

  return (
    <Paper className={classes.root}>
      <Table className={classes.table}>
        <TableHead>
          <TableRow>
            <TableCell>Id</TableCell>
            <TableCell>Name</TableCell>
            <TableCell>Slug</TableCell>
            <TableCell />
          </TableRow>
        </TableHead>
        <TableBody>
          {funds.map(fund => {
            return (
              <TableRow key={fund.id}>
                <TableCell>{fund.id}</TableCell>
                <TableCell scope='fund'>{fund.name}</TableCell>
                <TableCell scope='fund'>{fund.slug}</TableCell>
                <TableCell align='right'>
                  <a href={`/admin/funds/${fund.id}/edit`}>Edit</a>{' '}
                  <a
                    data-confirm='Are you sure?'
                    rel='nofollow'
                    data-method='delete'
                    href={`/admin/funds/${fund.id}`}
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

FundsTable.propTypes = {
  funds: PropTypes.array
}

FundsTable.defaultTypes = {
  funds: []
}
