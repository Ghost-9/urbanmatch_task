import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers.dart';
import '../utils/bottomsheet.dart';
import 'commit_screen.dart';

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
                                      return CommitScreen(
                                          commitModel: commitModel[0]);
                                    },
                                    error: (error, stackTrace) {
                                      throw Exception([error, stackTrace]);
                                    },
                                    loading: () => const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.black,
                                        )));
                              },
                            ))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          height: MediaQuery.of(context).size.height * 0.08,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model[index].name,
                                      style: TextStyle(
                                          fontSize: (MediaQuery.of(context)
                                                      .size
                                                      .aspectRatio *
                                                  2) *
                                              16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      model[index].description ?? "Description",
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: (MediaQuery.of(context)
                                                      .size
                                                      .aspectRatio *
                                                  2) *
                                              12,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                width: MediaQuery.of(context).size.width * 0.1,
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
