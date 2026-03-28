import '../../../../core/usecase/usecase.dart';
import '../entities/pin.dart';
import '../repositories/pin_repository.dart';

class GetPinsUseCase implements UseCase<List<Pin>, NoParams> {
  final PinRepository repository;

  GetPinsUseCase(this.repository);

  @override
  Future<List<Pin>> call(NoParams params) {
    return repository.getPins();
  }
}
