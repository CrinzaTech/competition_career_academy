import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/courses/data/models/course_model.dart';
import 'package:competition_career_academy/features/courses/domain/repositories/course_repository.dart';

class SaveCourseReviewUseCase {
  final CourseRepository repository;

  SaveCourseReviewUseCase(this.repository);

  Future<Either<Failure, List<CourseReview>>> call({
    required int courseId,
    required double rating,
    required String reviewMessage,
  }) {
    return repository.saveCourseReview(
      courseId: courseId,
      rating: rating,
      reviewMessage: reviewMessage,
    );
  }
}
