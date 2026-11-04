import 'package:dartz/dartz.dart';

import 'package:competition_career_academy/core/error/failures.dart';
import 'package:competition_career_academy/features/chats/data/models/chat_group_model.dart';
import 'package:competition_career_academy/features/chats/domain/repositories/chat_group_repository.dart';

class GetChatGroupsUseCase {
  final ChatGroupRepository repository;

  GetChatGroupsUseCase(this.repository);

  Future<Either<Failure, List<ChatGroupModel>>> call() {
    return repository.getChatGroups();
  }
}
