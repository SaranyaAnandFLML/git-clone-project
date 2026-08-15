import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/github_user.dart';
import '../../../models/github_repository_model.dart';
import '../../../core/common/api_constants.dart';

final githubUserRepositoryProvider = Provider<GithubUserRepository>((ref) {
  return GithubUserRepository();
});

class GithubUserRepository {
  Future<GithubUser> fetchUser(String username) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.gitUserProfile(username)}';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return GithubUser.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('unable to find');
    } else {
      throw Exception('Failed to load user. Please try again.');
    }
  }

  Future<List<GithubRepository>> fetchUserRepos(String username) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.gitUserRepos(username)}';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    log(response.statusCode.toString());
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GithubRepository.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('unable to find');
    } else {
      throw Exception('Failed to load repositories. Please try again.');
    }
  }
}
