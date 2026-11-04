import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/certificate/data/models/completed_course_model.dart';
import 'package:competition_career_academy/features/certificate/domain/repositories/certificate_repository.dart';

/// Every course the learner has finished, each carrying its own
/// `hasCertificate` flag.
class GetCompletedCoursesUseCase {
  final CertificateRepository repository;

  GetCompletedCoursesUseCase(this.repository);

  Future<Either<Failure, List<CompletedCourse>>> call() {
    return repository.getCompletedCourses();
  }
}
