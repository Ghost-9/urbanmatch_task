class CommitModel {
  final String? sha;
  final String? message;
  final String? url;
  final String? avatarUrl;
  final String? name;
  final String? commitDate;

  CommitModel(
      {this.sha,
      this.message,
      this.url,
      this.avatarUrl,
      this.name,
      this.commitDate});

  factory CommitModel.fromJson(Map<String, dynamic> json) {
    return CommitModel(
        sha: json['sha'],
        message: json['commit']['message'],
        url: json['html_url'],
        avatarUrl: json['author'] != null ? json['author']['avatar_url'] : null,
        name: json['commit']['author']['name'],
        commitDate: json['commit']['author']['date']);
  }

  @override
  String toString() {
    return 'CommitModel{sha: $sha, message: $message, url: $url, avatarUrl: $avatarUrl, name: $name, commitDate: $commitDate}';
  }
}
