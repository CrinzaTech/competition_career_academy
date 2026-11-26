import 'package:dartz/dartz.dart';
import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/payment/data/models/payment_model.dart';
import 'package:competition_career_academy/features/payment/domain/repositories/payment_repository.dart';

class CreateOrderUseCase {
  final PaymentRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, CreateOrderResponse>> call({
    required int courseId,
    required int priceId,
    String? couponCode,
    String? termsHash,
  }) {
    return repository.createOrder(
      courseId: courseId,
      priceId: priceId,
      couponCode: couponCode,
      termsHash: termsHash,
    );
  }
}
