import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/repo_model.dart';
import 'services/git_services.dart';

final repoProvider = FutureProvider.autoDispose<List<RepoModel>>(
    (ref) => GitApiRepository.fetchRepos());

final familyProvider = FutureProvider.autoDispose
    .family((ref, String url) => GitApiRepository.fetchLastCommit(url));
