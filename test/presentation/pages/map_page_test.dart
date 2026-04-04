import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/repositories/repository.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/presentation/pages/map_page.dart';
import 'package:tappin/presentation/providers/provider.dart';

import '../../helpers/mock_geocoding_service.dart';
import '../../helpers/mock_location_service.dart';
import '../../helpers/mock_repository.dart';

class _ErrorRepository implements Repository {
  @override
  Future<List<Pin>> getPins() async => throw Exception('DB error');
  @override
  Future<int> savePin(Pin pin) async => throw UnimplementedError();
  @override
  Future<void> deletePin(int id) async => throw UnimplementedError();
  @override
  Future<void> updateMemo(int id, Memo memo) async => throw UnimplementedError();
}

Widget _buildPage({Repository? repo}) {
  return ProviderScope(
    overrides: [
      useCaseProvider.overrideWithValue(UseCase(repo ?? MockRipository())),
      locationServiceProvider.overrideWithValue(
        MockLocationService.success(testCoordinate),
      ),
      geocodingServiceProvider.overrideWithValue(MockGeocodingService()),
    ],
    child: const MaterialApp(home: MapPage()),
  );
}

void main() {
  testWidgets('ローディング中は CircularProgressIndicator が表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    // pumpAndSettle前（loading状態）
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppBarに「マップ」が表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('マップ'), findsOneWidget);
  });

  testWidgets('エラー時にエラーメッセージが表示される', (tester) async {
    await tester.pumpWidget(_buildPage(repo: _ErrorRepository()));
    await tester.pumpAndSettle();

    expect(find.textContaining('エラー'), findsOneWidget);
  });

  testWidgets('Pinがない場合にマップが描画される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('Pinがある場合にマップが描画される', (tester) async {
    final pins = [buildTestPin(id: 1), buildTestPin(id: 2)];
    await tester.pumpWidget(_buildPage(repo: MockRipository(stubbedPins: pins)));
    await tester.pumpAndSettle();

    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('現在地ボタン（FAB）が表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
