import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

class GetExamResultUseCase {
  final ExamRepository repository;

  GetExamResultUseCase(this.repository);

  Future<Either<Failure, ExamResultResponse>> call({
    required int attemptId,
    required String phoneNumber,
  }) {
    return repository.getResult(attemptId: attemptId, phoneNumber: phoneNumber);
  }
}
