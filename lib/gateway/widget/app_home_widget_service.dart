import 'package:home_widget/home_widget.dart';

import 'package:tappin/domain/services/home_widget_service.dart';

class AppHomeWidgetService implements HomeWidgetService {
  @override
  Future<void> update({required String address, required String timestamp}) async {
    await HomeWidget.saveWidgetData<String>('address', address);
    await HomeWidget.saveWidgetData<String>('timestamp', timestamp);
    await HomeWidget.updateWidget(androidName: 'TappinWidgetProvider');
  }
}
