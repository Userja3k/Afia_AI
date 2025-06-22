import 'package:latlong2/latlong.dart';

class LocationService {
  Future<LatLng> getCurrentLocation() async {
    // Simulation d'une localisation (Dakar, Sénégal)
    // Dans une vraie app, utiliser geolocator package
    return const LatLng(14.6928, -17.4467);
  }

  Future<List<Map<String, dynamic>>> getNearbyHospitals(LatLng location) async {
    // Simulation d'hôpitaux proches
    // Dans une vraie app, utiliser une API comme Overpass ou Google Places
    return [
      {
        'name': 'Hôpital Principal de Dakar',
        'lat': 14.6937,
        'lng': -17.4441,
        'distance': 0.8,
        'phone': '+221 33 839 50 50',
      },
      {
        'name': 'Clinique Pasteur',
        'lat': 14.6889,
        'lng': -17.4516,
        'distance': 1.2,
        'phone': '+221 33 889 02 02',
      },
      {
        'name': 'Hôpital Aristide Le Dantec',
        'lat': 14.6945,
        'lng': -17.4398,
        'distance': 1.5,
        'phone': '+221 33 889 01 01',
      },
    ];
  }
}
