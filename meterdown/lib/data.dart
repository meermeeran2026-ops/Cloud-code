/// नमूना डेटा। असली सर्वर जुड़ने पर यह फ़ाइल हट जाएगी।
class Place {
  final String name;
  final String area;
  final double km;
  const Place(this.name, this.area, this.km);
  int get minutes => (km * 4.3).round();
}

/// गाड़ी के प्रकार: ऑटो और कार (बाइक नहीं)।
class Vehicle {
  final String key;
  final bool car;
  final int seats;
  final int base;
  final int perKm;
  final int eta;
  const Vehicle(
    this.key,
    this.car,
    this.seats,
    this.base,
    this.perKm,
    this.eta,
  );
  int fare(double km) => (base + km * perKm).round();
}

const vehicles = [
  Vehicle('auto', false, 3, 30, 12, 4),
  Vehicle('car', true, 4, 50, 16, 6),
  Vehicle('sedan', true, 4, 70, 20, 8),
];

/// एक बुकिंग: कहाँ, किस गाड़ी से, कैसे भुगतान।
class Trip {
  final Place place;
  final Vehicle vehicle;
  final bool upi;
  const Trip(this.place, this.vehicle, {this.upi = false});
  int get fare => vehicle.fare(place.km);
}

const pickupName = 'Station Road, Gate 2';

const places = [
  Place('City Mall', 'Main Road', 2.8),
  Place('District Hospital', 'Civil Lines', 4.1),
  Place('Bus Stand', 'Old City', 3.4),
  Place('Sabzi Mandi', 'Gandhi Chowk', 1.9),
  Place('University Gate', 'Campus Road', 6.2),
  Place('Collectorate', 'Court Road', 5.0),
];

const driverName = 'Ramesh Yadav';
const riderName = 'Anita Sharma';

class PastRide {
  final String to;
  final String? dayKey;
  final String when;
  final int fare;
  final bool upi;
  final bool car;
  const PastRide(
    this.to,
    this.dayKey,
    this.when,
    this.fare, {
    this.upi = false,
    this.car = false,
  });
}

const pastRides = [
  PastRide('City Mall', 'today', '9:40 AM', 64),
  PastRide(
    'District Hospital',
    'yesterday',
    '6:15 PM',
    116,
    upi: true,
    car: true,
  ),
  PastRide('Bus Stand', null, '12 Nov · 1:05 PM', 71),
  PastRide('Sabzi Mandi', null, '10 Nov · 8:20 AM', 53, upi: true),
];
