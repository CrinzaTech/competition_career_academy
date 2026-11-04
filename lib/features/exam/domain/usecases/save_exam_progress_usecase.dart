import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

class SaveExamProgressUseCase {
  final ExamRepository repository;

  SaveExamProgressUseCase(this.repository);

  Future<Either<Failure, SaveProgressResponse>> call({
    required int attemptId,
    required String phoneNumber,
    required List<Map<String, dynamic>> answers,
  }) {
    return repository.saveProgress(
      attemptId: attemptId,
      phoneNumber: phoneNumber,
      answers: answers,
    );
  }
}
