import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/github_user.dart';
import '../../../core/common/api_constants.dart';

final githubUserRepositoryProvider = Provider<GithubUserRepository>((ref) {
  return GithubUserRepository();
});

class GithubUserRepository {
  Future<GithubUser> fetchUser(String username) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.gitUserProfile(username)}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return GithubUser.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load user. Please try again.');
    }
  }
}
