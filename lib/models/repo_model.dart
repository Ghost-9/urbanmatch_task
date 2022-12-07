class RepoModel {
  final String name;
  final String? description;
  final String? language;
  final String? url;
  final String? avatarUrl;
  final int? stargazersCount, watchersCount, forksCount;
  final String? commitsUrl;

  RepoModel(
      {required this.name,
      this.description,
      this.language,
      this.url,
      this.avatarUrl,
      this.forksCount,
      this.stargazersCount,
      this.watchersCount,
      this.commitsUrl});

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      name: json['name'],
      description: json['description'],
      language: json['language'],
      url: json['html_url'],
      avatarUrl: json['owner']['avatar_url'],
      stargazersCount: json['stargazers_count'],
      watchersCount: json['watchers_count'],
      forksCount: json['forks_count'],
      commitsUrl: json['commits_url'],
    );
  }
  @override
  String toString() {
    return 'RepoModel{name: $name, description: $description, language: $language, url: $url, avatarUrl: $avatarUrl, stargazersCount: $stargazersCount, watchersCount: $watchersCount, forksCount: $forksCount, commitsUrl: $commitsUrl}';
  }
}
