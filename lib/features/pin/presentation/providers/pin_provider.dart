import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/pin_local_datasource.dart';
import '../../data/repositories/pin_repository_impl.dart';
import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/delete_pin_usecase.dart';
import '../../domain/usecases/get_pins_usecase.dart';
import '../../domain/usecases/save_pin_usecase.dart';
import '../../../../core/usecase/usecase.dart';

final databaseProvider = FutureProvider<Database>((ref) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'tappin.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await PinLocalDatasourceImpl.createTable(db);
    },
  );
});

final pinLocalDatasourceProvider = Provider<PinLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return PinLocalDatasourceImpl(db);
});

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  final datasource = ref.watch(pinLocalDatasourceProvider);
  return PinRepositoryImpl(datasource);
});

final savePinUseCaseProvider = Provider<SavePinUseCase>((ref) {
  return SavePinUseCase(ref.watch(pinRepositoryProvider));
});

final getPinsUseCaseProvider = Provider<GetPinsUseCase>((ref) {
  return GetPinsUseCase(ref.watch(pinRepositoryProvider));
});

final deletePinUseCaseProvider = Provider<DeletePinUseCase>((ref) {
  return DeletePinUseCase(ref.watch(pinRepositoryProvider));
});

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() async {
    final useCase = ref.watch(getPinsUseCaseProvider);
    return useCase(const NoParams());
  }

  Future<void> savePin(Pin pin) async {
    await ref.read(savePinUseCaseProvider)(pin);
    ref.invalidateSelf();
  }

  Future<void> deletePin(int id) async {
    await ref.read(deletePinUseCaseProvider)(id);
    ref.invalidateSelf();
  }
}
