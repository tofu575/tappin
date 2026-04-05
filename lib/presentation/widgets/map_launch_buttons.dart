import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tappin/domain/models/location/coordinate.dart';

const _googleMapsBaseUrl =
    'https://www.google.com/maps/search/?api=1&query=';
const _streetViewBaseUrl =
    'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=';

class MapLaunchButtons extends StatelessWidget {
  const MapLaunchButtons({super.key, required this.coordinate});

  final Coordinate coordinate;

  String get _coordQuery =>
      '${coordinate.latitude.value},${coordinate.longitude.value}';

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse('$_googleMapsBaseUrl$_coordQuery');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openStreetView() async {
    final uri = Uri.parse('$_streetViewBaseUrl$_coordQuery');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.map),
          tooltip: 'Google Maps',
          onPressed: _openGoogleMaps,
        ),
        IconButton(
          icon: const Icon(Icons.streetview),
          tooltip: 'ストリートビュー',
          onPressed: _openStreetView,
        ),
      ],
    );
  }
}
