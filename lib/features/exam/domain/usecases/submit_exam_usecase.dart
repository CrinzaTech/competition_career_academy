import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

class SubmitExamUseCase {
  final ExamRepository repository;

  SubmitExamUseCase(this.repository);

  Future<Either<Failure, ExamResultResponse>> call({
    required int attemptId,
    required String phoneNumber,
    required bool autoSubmitted,
    required List<Map<String, dynamic>> answers,
  }) {
    return repository.submit(
      attemptId: attemptId,
      phoneNumber: phoneNumber,
      autoSubmitted: autoSubmitted,
      answers: answers,
    );
  }
}
