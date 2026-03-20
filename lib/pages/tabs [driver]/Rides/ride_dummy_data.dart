// ════════════════════════════════════════════════════════════════════
//  ride_dummy_data.dart
// ════════════════════════════════════════════════════════════════════

import 'ride_model.dart';

final List<RideModel> dummyRides = [
  RideModel(
    id: 'RD-00421',
    passengerName: 'Sarah Mitchell',
    passengerAvatar: 'SM',
    passengerCount: 2,
    from: 'Downtown Plaza, Main St',
    to: 'Airport Terminal 2',
    dateTime: DateTime.now().add(const Duration(minutes: 12)),
    price: 34.50,
    status: RideStatus.available,
  ),
  RideModel(
    id: 'RD-00418',
    passengerName: 'Carlos Rivera',
    passengerAvatar: 'CR',
    passengerCount: 2,
    from: 'Harbour View Hotel',
    to: 'Tech Park, Building 7',
    dateTime: DateTime.now().add(const Duration(hours: 3)),
    price: 22.00,
    status: RideStatus.upcoming,
  ),

  RideModel(
    id: 'RD-00401',
    passengerName: 'Tom Nguyen',
    passengerAvatar: 'TN',
    passengerCount: 4,
    from: 'Sunset Boulevard 22',
    to: 'Opera House Square',
    dateTime: DateTime.now().subtract(const Duration(days: 1)),
    price: 41.00,
    status: RideStatus.completed,
  ),
  RideModel(
    id: 'RD-00395',
    passengerName: 'Felix Wagner',
    passengerAvatar: 'FW',
    passengerCount: 2,
    from: 'East Market Square',
    to: 'Stadium North Gate',
    dateTime: DateTime.now().subtract(const Duration(days: 3)),
    price: 19.00,
    status: RideStatus.cancelled,
  ),
];