import ReactOnRails from 'react-on-rails'

import { UserShow } from '../bundles/User/components/UserShow'
import { DonationsHistory } from '../bundles/User/components/DonationsHistory'
import { SubscriptionCancel } from '../bundles/User/components/SubscriptionCancel'
import Drawer from '../bundles/User/components/Drawer'

ReactOnRails.register({
  UserShow,
  DonationsHistory,
  SubscriptionCancel,
  Drawer
})
