import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tappin/features/pin/data/storages/pin_local_storage.dart';
import 'package:tappin/features/pin/data/repositories/pin_repository_impl.dart';
import 'package:tappin/features/pin/domain/repositories/pin_repository.dart';
import 'package:tappin/features/pin/domain/usecases/delete_pin_usecase.dart';
import 'package:tappin/features/pin/domain/usecases/get_pins_usecase.dart';
import 'package:tappin/features/pin/domain/usecases/save_pin_usecase.dart';

const _dbName = 'tappin.db';

final databaseProvider = FutureProvider<Database>((ref) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, _dbName);
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await PinSQLiteStorage.createTable(db);
    },
  );
});

final pinRepositoryProvider = FutureProvider<PinRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return PinRepositoryImpl(PinSQLiteStorage(db));
});

final savePinUseCaseProvider = FutureProvider<SavePinUseCase>((ref) async {
  final repository = await ref.watch(pinRepositoryProvider.future);
  return SavePinUseCase(repository);
});

final getPinsUseCaseProvider = FutureProvider<GetPinsUseCase>((ref) async {
  final repository = await ref.watch(pinRepositoryProvider.future);
  return GetPinsUseCase(repository);
});

final deletePinUseCaseProvider = FutureProvider<DeletePinUseCase>((ref) async {
  final repository = await ref.watch(pinRepositoryProvider.future);
  return DeletePinUseCase(repository);
});
