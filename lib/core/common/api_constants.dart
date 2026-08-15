class ApiConstants {
  static final String baseUrl= 'https://api.github.com';
  static String gitUserProfile(String userName)=> '/users/$userName';
  static String gitUserRepos(String userName)=> '/users/$userName/repos';
}