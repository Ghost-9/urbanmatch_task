import 'dart:convert';

import '../models/commit_model.dart';
import '../models/repo_model.dart';
import 'package:http/http.dart' as http;

import '../utils/const.dart';

class GitApiRepository {
  static Future<List<RepoModel>> fetchRepos() async {
    final response =
        await http.get(Uri.parse('${Constants.apiEndpoint}freeCodeCamp/repos'));
    if (response.statusCode == 200) {
      final List<dynamic> repos = jsonDecode(response.body);
      return repos.map((repo) => RepoModel.fromJson(repo)).toList();
    } else {
      throw Exception('Failed to load repos');
    }
  }

  static Future<List<CommitModel>> fetchLastCommit(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> commit = jsonDecode(response.body);
      return commit.map((commits) => CommitModel.fromJson(commits)).toList();
    } else {
      throw Exception('Failed to load commit');
    }
  }
}
