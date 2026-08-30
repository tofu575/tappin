import 'package:url_launcher/url_launcher.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/services/external_map_destination.dart';
import 'package:tappin/domain/services/external_map_gateway.dart';

const _googleMapsBaseUrl = 'https://www.google.com/maps/search/?api=1&query=';
const _streetViewBaseUrl =
    'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=';

/// url_launcherでGoogle MapsまたはStreet Viewを開くGateway。
class UrlLauncherExternalMapGateway implements ExternalMapGateway {
  const UrlLauncherExternalMapGateway();

  @override
  Future<void> open({
    required Coordinate coordinate,
    required ExternalMapDestination destination,
  }) async {
    final coordinateQuery =
        '${coordinate.latitude.value},${coordinate.longitude.value}';
    final baseUrl = switch (destination) {
      ExternalMapDestination.map => _googleMapsBaseUrl,
      ExternalMapDestination.streetView => _streetViewBaseUrl,
    };
    final uri = Uri.parse('$baseUrl$coordinateQuery');
    if (!await canLaunchUrl(uri)) throw ExternalMapLaunchException(uri);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// 外部地図アプリで[uri]を開けなかったことを表す。
class ExternalMapLaunchException implements Exception {
  const ExternalMapLaunchException(this.uri);

  final Uri uri;
}
