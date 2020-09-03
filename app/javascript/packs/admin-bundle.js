import ReactOnRails from 'react-on-rails'

import Drawer from '../bundles/Admin/components/Drawer'
import { UsersTable } from '../bundles/Admin/components/Users'
import { SubscriptionsTable } from '../bundles/Admin/components/Subscriptions'
import { PlansTable } from '../bundles/Admin/components/Plans'
import { FundsTable } from '../bundles/Admin/components/Funds'
import { DonationsTable } from '../bundles/Admin/components/Donations'
import { Dashboard } from '../bundles/Admin/components/Dashboard'

ReactOnRails.register({
  Drawer,
  UsersTable,
  SubscriptionsTable,
  PlansTable,
  FundsTable,
  DonationsTable,
  Dashboard
})
