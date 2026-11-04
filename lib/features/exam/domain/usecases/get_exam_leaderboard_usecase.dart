import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/entities/exam_context.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

class GetExamLeaderboardUseCase {
  final ExamRepository repository;

  GetExamLeaderboardUseCase(this.repository);

  /// [top] is the rank cut-off the server should return down to (default 10,
  /// clamped server-side to 1-50), not a row count.
  Future<Either<Failure, ExamLeaderboard>> call({
    required int examId,
    required String phoneNumber,
    ExamContext context = ExamContext.standalone,
    int top = 10,
  }) {
    return repository.getLeaderboard(
      examId: examId,
      phoneNumber: phoneNumber,
      context: context,
      top: top,
    );
  }
}
