import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/entities/exam_context.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

class GetExamGateUseCase {
  final ExamRepository repository;

  GetExamGateUseCase(this.repository);

  Future<Either<Failure, AttemptStateResponse>> call({
    required int examId,
    required String phoneNumber,
    ExamContext context = ExamContext.standalone,
  }) {
    return repository.getGate(
      examId: examId,
      phoneNumber: phoneNumber,
      context: context,
    );
  }
}
