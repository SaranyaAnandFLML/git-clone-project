class GithubRepository {
  final String name;
  final String? description;
  final int stargazersCount;
  final String? language;
  final DateTime? updatedAt;

  GithubRepository({
    required this.name,
    this.description,
    required this.stargazersCount,
    this.language,
    this.updatedAt,
  });

  factory GithubRepository.fromJson(Map<String, dynamic> json) {
    return GithubRepository(
      name: json['name'] ?? '',
      description: json['description'],
      stargazersCount: json['stargazers_count'] ?? 0,
      language: json['language'],
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}
