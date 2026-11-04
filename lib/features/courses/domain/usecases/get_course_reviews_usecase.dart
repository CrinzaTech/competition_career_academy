import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/courses/data/models/course_model.dart';
import 'package:competition_career_academy/features/courses/domain/repositories/course_repository.dart';

class GetCourseReviewsUseCase {
  final CourseRepository repository;

  GetCourseReviewsUseCase(this.repository);

  Future<Either<Failure, List<CourseReview>>> call({required int courseId}) {
    return repository.getCourseReviews(courseId);
  }
}
