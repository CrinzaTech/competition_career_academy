import 'package:dartz/dartz.dart';
import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/home/data/models/home_model.dart';

/// Home repository interface
abstract class HomeRepository {
  /// Get dashboard data
  Future<Either<Failure, DashboardData>> getDashboard();
}
