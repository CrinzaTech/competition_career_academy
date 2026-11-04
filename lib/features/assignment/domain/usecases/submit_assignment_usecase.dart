import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/assignment/data/models/assignment_model.dart';
import 'package:competition_career_academy/features/assignment/domain/repositories/assignment_repository.dart';

class SubmitAssignmentUseCase {
  final AssignmentRepository repository;

  SubmitAssignmentUseCase(this.repository);

  Future<Either<Failure, Assignment>> call({
    required int courseId,
    required int assignmentId,
    required String jsonNodeId,
    required int submissionId,
    required File file,
  }) {
    return repository.submitAssignment(
      courseId: courseId,
      assignmentId: assignmentId,
      jsonNodeId: jsonNodeId,
      submissionId: submissionId,
      file: file,
    );
  }
}
