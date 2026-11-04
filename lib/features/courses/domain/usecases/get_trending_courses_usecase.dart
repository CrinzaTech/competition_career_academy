import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/courses/data/models/course_filter_models.dart';
import 'package:competition_career_academy/features/courses/data/models/course_model.dart';
import 'package:competition_career_academy/features/courses/domain/repositories/course_repository.dart';

class GetTrendingCoursesUseCase {
  final CourseRepository repository;

  GetTrendingCoursesUseCase(this.repository);

  Future<Either<Failure, CourseCatalogResponse>> call({int? pageNo}) {
    return repository.getCatalog(
      sortBy: CatalogSortBy.trending,
      pageNo: pageNo,
    );
  }
}
