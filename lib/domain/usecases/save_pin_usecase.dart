import 'package:tappin/core/usecase/usecase.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/repositories/pin_repository.dart';

class SavePinUseCase implements UseCase<int, Pin> {
  final PinRepository repository;

  SavePinUseCase(this.repository);

  @override
  Future<int> call(Pin params) {
    return repository.savePin(params);
  }
}
