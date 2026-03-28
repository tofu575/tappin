import '../../../../core/usecase/usecase.dart';
import '../entities/pin.dart';
import '../repositories/pin_repository.dart';

class SavePinUseCase implements UseCase<int, Pin> {
  final PinRepository repository;

  SavePinUseCase(this.repository);

  @override
  Future<int> call(Pin params) {
    return repository.savePin(params);
  }
}
