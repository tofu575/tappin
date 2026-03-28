import 'package:tappin/core/usecase/usecase.dart';
import 'package:tappin/domain/repositories/pin_repository.dart';

class DeletePinUseCase implements UseCase<void, int> {
  final PinRepository repository;

  DeletePinUseCase(this.repository);

  @override
  Future<void> call(int params) {
    return repository.deletePin(params);
  }
}
