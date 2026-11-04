import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/courses/data/models/course_model.dart';
import 'package:competition_career_academy/features/courses/domain/repositories/course_repository.dart';

class GetContinueCoursesUseCase {
  final CourseRepository repository;

  GetContinueCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseSummary>>> call() {
    return repository.getContinueCourses();
  }
}
