import 'package:tappin/core/usecase/usecase.dart';
import 'package:tappin/features/pin/domain/models/pin/pin.dart';
import 'package:tappin/features/pin/domain/repositories/pin_repository.dart';

class GetPinsUseCase implements UseCase<List<Pin>, NoParams> {
  final PinRepository repository;

  GetPinsUseCase(this.repository);

  @override
  Future<List<Pin>> call(NoParams params) {
    return repository.getPins();
  }
}
