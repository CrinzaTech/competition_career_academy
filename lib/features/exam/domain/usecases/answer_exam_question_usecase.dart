import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

class AnswerExamQuestionUseCase {
  final ExamRepository repository;

  AnswerExamQuestionUseCase(this.repository);

  Future<Either<Failure, CompetitiveAnswerResultResponse>> call({
    required int attemptId,
    required String phoneNumber,
    required Map<String, dynamic> answer,
  }) {
    return repository.answerQuestion(
      attemptId: attemptId,
      phoneNumber: phoneNumber,
      answer: answer,
    );
  }
}
