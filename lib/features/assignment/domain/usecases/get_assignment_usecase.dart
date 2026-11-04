import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/assignment/data/models/assignment_model.dart';
import 'package:competition_career_academy/features/assignment/domain/repositories/assignment_repository.dart';

class GetAssignmentUseCase {
  final AssignmentRepository repository;

  GetAssignmentUseCase(this.repository);

  Future<Either<Failure, Assignment>> call({
    required int assignmentId,
    required String nodeId,
  }) {
    return repository.getAssignment(
      assignmentId: assignmentId,
      nodeId: nodeId,
    );
  }
}
