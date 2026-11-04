import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/webinar/data/models/webinar_model.dart';
import 'package:competition_career_academy/features/webinar/domain/repositories/webinar_repository.dart';

/// One webinar, by slug — the payload behind the detail screen.
class GetWebinarDetailUseCase {
  final WebinarRepository repository;

  GetWebinarDetailUseCase(this.repository);

  Future<Either<Failure, WebinarDetail>> call(String slug) {
    return repository.getWebinarDetail(slug);
  }
}
