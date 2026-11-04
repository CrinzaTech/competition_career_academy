import 'package:dartz/dartz.dart';
import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/auth/domain/repositories/otp_repository.dart';

class SendOtpUseCase {
  final OtpRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, void>> call({required String mobileNumber}) {
    return repository.sendOtp(mobileNumber: mobileNumber);
  }
}
