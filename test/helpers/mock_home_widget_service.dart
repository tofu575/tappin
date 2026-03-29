import 'package:tappin/domain/services/home_widget_service.dart';

class MockHomeWidgetService implements HomeWidgetService {
  final List<({String address, String timestamp})> updates = [];

  @override
  Future<void> update({required String address, required String timestamp}) async {
    updates.add((address: address, timestamp: timestamp));
  }
}
