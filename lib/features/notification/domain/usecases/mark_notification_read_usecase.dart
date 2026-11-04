import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  const MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> call({required int notificationId}) {
    return repository.markAsRead(notificationId);
  }
}
