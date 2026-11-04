import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/courses/data/models/course_model.dart';
import 'package:competition_career_academy/features/courses/domain/repositories/course_repository.dart';

class GetCoursesByTileUseCase {
  final CourseRepository repository;

  GetCoursesByTileUseCase(this.repository);

  Future<Either<Failure, CourseCatalogResponse>> call({
    required int tileId,
    bool? isPaid,
    int? pageNo,
  }) {
    return repository.getCatalog(
      tileId: tileId,
      courseType: isPaid == true ? 'Paid' : (isPaid == false ? 'Free' : null),
      pageNo: pageNo,
    );
  }
}
