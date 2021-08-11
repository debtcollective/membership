import React from 'react'
import PropTypes from 'prop-types'
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

export default function UsersTable ({ users }) {
  const classes = useStyles()

  return (
    <Paper className={classes.root}>
      <Table className={classes.table}>
        <TableHead>
          <TableRow>
            <TableCell>Name</TableCell>
            <TableCell>Email</TableCell>
            <TableCell>Stripe ID</TableCell>
            <TableCell>Discourse</TableCell>
            <TableCell />
          </TableRow>
        </TableHead>
        <TableBody>
          {users.map(user => (
            <TableRow key={user.id}>
              <TableCell scope='user'>{user.name}</TableCell>
              <TableCell>{user.email}</TableCell>
              <TableCell>{user.stripe_id ? user.stripe_id : 'N/A'}</TableCell>
              <TableCell>{user.external_id}</TableCell>
              <TableCell align='right'>
                <a href={`/admin/users/${user.id}`}>Show</a>{' '}
                <a href={`/admin/users/${user.id}/edit`}>Edit</a>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </Paper>
  )
}

UsersTable.propTypes = {
  users: PropTypes.array,
}

UsersTable.defaultTypes = {
  users: [],
}
