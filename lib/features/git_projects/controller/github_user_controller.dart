import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/github_user.dart';
import '../repository/github_user_repository.dart';

final githubUserControllerProvider = Provider<GithubUserController>((ref) {
  final repository = ref.watch(githubUserRepositoryProvider);
  return GithubUserController(repository);
});

class GithubUserController {
  final GithubUserRepository _repository;

  GithubUserController(this._repository);

  Future<GithubUser> fetchUser(String username) async {
    return await _repository.fetchUser(username);
  }
}

final searchUsernameProvider = StateProvider<String>((ref) => '');

final githubUserFutureProvider = FutureProvider<GithubUser?>((ref) async {
  final username = ref.watch(searchUsernameProvider);
  if (username.trim().isEmpty) return null;
  
  final controller = ref.watch(githubUserControllerProvider);
  return controller.fetchUser(username.trim());
});
