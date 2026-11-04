import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/courses/data/models/course_filter_models.dart';
import 'package:competition_career_academy/features/courses/domain/repositories/course_repository.dart';

class GetCourseCategoriesUseCase {
  final CourseRepository repository;

  GetCourseCategoriesUseCase(this.repository);

  Future<Either<Failure, CourseFilterData>> call() {
    return repository.getCourseCategories();
  }
}
