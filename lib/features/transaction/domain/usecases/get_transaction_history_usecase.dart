import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/transaction/data/models/transaction_model.dart';
import 'package:competition_career_academy/features/transaction/domain/repositories/transaction_repository.dart';

/// Wraps the optional filter+paymentStatus pair through to the repo.
/// Both params default to `null` — callers can omit them when no filter
/// is active and the URL stays clean.
class GetTransactionHistoryUseCase {
  final TransactionRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<Either<Failure, List<TransactionModel>>> call({
    String? paymentStatus,
    String? filter,
    String? itemType,
  }) {
    return repository.getHistory(
      paymentStatus: paymentStatus,
      filter: filter,
      itemType: itemType,
    );
  }
}
