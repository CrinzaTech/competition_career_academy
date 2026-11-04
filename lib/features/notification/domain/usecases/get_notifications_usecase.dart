import 'package:dartz/dartz.dart';
import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/notification/data/models/notification_model.dart';
import 'package:competition_career_academy/features/notification/domain/repositories/notification_repository.dart';

/// Get all notifications use case
class GetNotificationsUseCase {
  final NotificationRepository repository;

  const GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationModel>>> call() async {
    return await repository.getNotifications();
  }
}
