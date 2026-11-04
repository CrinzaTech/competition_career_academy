import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/exam/data/models/exam_models.dart';
import 'package:competition_career_academy/features/exam/domain/repositories/exam_repository.dart';

/// Practice drill: fetch the whole paper (re-dealt per call when the exam shuffles).
class GetPracticePaperUseCase {
  final ExamRepository repository;

  GetPracticePaperUseCase(this.repository);

  Future<Either<Failure, ExamPaperResponse>> call({
    required int examId,
    required String phoneNumber,
  }) {
    return repository.getPracticePaper(
      examId: examId,
      phoneNumber: phoneNumber,
    );
  }
}
