import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/transaction/data/models/receipt_model.dart';
import 'package:competition_career_academy/features/transaction/domain/repositories/transaction_repository.dart';

class DownloadReceiptUseCase {
  final TransactionRepository repository;

  DownloadReceiptUseCase(this.repository);

  Future<Either<Failure, ReceiptModel>> call(int transactionId) {
    return repository.downloadReceipt(transactionId);
  }
}

/// A store order's invoice (or payment receipt before it ships).
class DownloadStoreInvoiceUseCase {
  final TransactionRepository repository;

  DownloadStoreInvoiceUseCase(this.repository);

  Future<Either<Failure, ReceiptModel>> call(String orderNo) {
    return repository.downloadStoreInvoice(orderNo);
  }
}
