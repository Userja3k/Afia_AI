import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/gradient_button.dart';
import '../../utils/i18n/app_localizations.dart';
import '../../services/location_service.dart';

class TraitementMalariaPage extends StatefulWidget {
  final Map<String, dynamic> diagnostic;

  const TraitementMalariaPage({
    super.key,
    required this.diagnostic,
  });

  @override
  State<TraitementMalariaPage> createState() => _TraitementMalariaPageState();
}

class _TraitementMalariaPageState extends State<TraitementMalariaPage> {
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _nearbyHospitals = [];
  LatLng? _currentLocation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearbyHospitals();
  }

  Future<void> _loadNearbyHospitals() async {
    try {
      final location = await _locationService.getCurrentLocation();
      final hospitals = await _locationService.getNearbyHospitals(location);
      if (!mounted) return;
      setState(() {
        _currentLocation = location;
        _nearbyHospitals = hospitals;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Erreur lors de la récupération des hôpitaux à proximité.";
      });
    }
  }

  Color _getSeverityColor() {
    final severity = widget.diagnostic['gravite'] ?? 'modérée';
    switch (severity) {
      case 'élevée':
        return Colors.red;
      case 'modérée':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final isUrgent = widget.diagnostic['urgence'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('malaria.result.title')),
        backgroundColor: _getSeverityColor(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: _getSeverityColor().withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isUrgent ? Icons.warning : Icons.info,
                          color: _getSeverityColor(),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.diagnostic['diagnostic'] ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${i18n.translate('malaria.result.severity')}: ${widget.diagnostic['gravite']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.translate('malaria.result.recommendations'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...((widget.diagnostic['recommandations']
                                as List<String>?) ??
                            [])
                        .map((rec) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(rec)),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ),
            if (isUrgent && _currentLocation != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        i18n.translate('malaria.result.nearby_hospitals'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      if (_nearbyHospitals.isEmpty && _error == null)
                        Text(AppLocalizations.of(context)
                            .translate('malaria.result.no_nearby_hospitals')),
                      if (_nearbyHospitals.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: FlutterMap(
                            options: MapOptions(
                              center: _currentLocation!,
                              zoom: 13.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _currentLocation!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.person_pin_circle,
                                      color: Colors.blue,
                                      size: 40,
                                    ),
                                  ),
                                  ..._nearbyHospitals
                                      .map((hospital) => Marker(
                                            point: LatLng(hospital['lat'],
                                                hospital['lng']),
                                            width: 40,
                                            height: 40,
                                            child: const Icon(
                                              Icons.local_hospital,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            GradientButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(i18n.translate('common.back_home')),
            ),
          ],
        ),
      ),
    );
  }
}
