import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ProviderScope(child: HomePage()));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const RepoListView());
  }
}

class RepoListView extends ConsumerWidget {
  const RepoListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repos = ref.watch(repoProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Git Repositories"),
        centerTitle: true,
      ),
      body: repos.when(data: (model) {
        return AnimationLimiter(
          child: ListView.builder(
            itemBuilder: ((context, index) {
              return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: (() => bottomSheet(context, Consumer(
                              builder: (context, ref, child) {
                                final lastCommit = ref.watch(familyProvider(
                                    model[index]
                                        .commitsUrl!
                                        .replaceAll("{/sha}", "")));
                                return lastCommit.when(
                                    data: (commitModel) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Center(
                                            child: Text(
                                              "Last Commit Details",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                      color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                fit: BoxFit.contain,
                                                image: NetworkImage(
                                                  commitModel.first.avatarUrl!,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                    error: (error, stackTrace) {
                                      throw Exception([error, stackTrace]);
                                    },
                                    loading: () => const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )));
                              },
                            ))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model[index].name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      model[index].description ?? "Description",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            model[index].avatarUrl!))),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
            }),
            itemCount: model.length,
          ),
        );
      }, error: (error, stackTrace) {
        throw Exception([error, stackTrace]);
      }, loading: () {
        return const Center(
            child: CircularProgressIndicator(
          color: Colors.white,
        ));
      }),
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyText2,
        titleTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).headline6,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        color: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).bodyText2,
        titleTextStyle: const TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).headline6,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
    );
  }
}

final repoProvider = FutureProvider.autoDispose<List<RepoModel>>(
    (ref) => GitApiRepository.fetchRepos());

final familyProvider = FutureProvider.autoDispose
    .family((ref, String url) => GitApiRepository.fetchLastCommit(url));

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

class Constants {
  static const String apiEndpoint = 'https://api.github.com/users/';
}

class CommitModel {
  final String? sha;
  final String? message;
  final String? url;
  final String? avatarUrl;
  final String? name;

  CommitModel({this.sha, this.message, this.url, this.avatarUrl, this.name});

  factory CommitModel.fromJson(Map<String, dynamic> json) {
    return CommitModel(
        sha: json['sha'],
        message: json['commit']['message'],
        url: json['html_url'],
        avatarUrl: json['author']['avatar_url'],
        name: json['commit']['author']['name']);
  }

  @override
  String toString() {
    return 'CommitModel{sha: $sha, message: $message, url: $url, avatarUrl: $avatarUrl, name: $name}';
  }
}

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

void bottomSheet(BuildContext context, Widget child) => showModalBottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          // color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey,
                ),
              ),
            ),
            child,
          ],
        ),
      );
    });
