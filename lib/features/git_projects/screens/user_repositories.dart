import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/github_user_controller.dart';

final repoSortProvider = StateProvider<String>((ref) => 'Stars');

class UserRepositories extends ConsumerWidget {
  const UserRepositories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(searchUsernameProvider);
    final sortOption = ref.watch(repoSortProvider);

    if (username.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Repositories'),
        ),
        body: const Center(
          child: Text('No user selected.'),
        ),
      );
    }

    final reposState =
    ref.watch(githubUserReposFutureProvider(username));

    return Scaffold(
      appBar: AppBar(
        title: Text("$username",style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              ref.read(repoSortProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Stars',
                child: Text('Sort by Stars'),
              ),
              const PopupMenuItem(
                value: 'Recently Updated',
                child: Text('Sort by Recently Updated'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: reposState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (repos) {
          if (repos.isEmpty) {
            return const Center(
              child: Text('No repositories found.'),
            );
          }

          final sortedRepos = List.of(repos);
          if (sortOption == 'Stars') {
            sortedRepos.sort((a, b) => b.stargazersCount.compareTo(a.stargazersCount));
          } else {
            sortedRepos.sort((a, b) {
              if (a.updatedAt == null && b.updatedAt == null) return 0;
              if (a.updatedAt == null) return 1;
              if (b.updatedAt == null) return -1;
              return b.updatedAt!.compareTo(a.updatedAt!);
            });
          }

          return ListView.builder(
            itemCount: sortedRepos.length,
            itemBuilder: (context, index) {
              final repo = sortedRepos[index];

              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                child: ListTile(
                  title: Text(
                    repo.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      if (repo.description != null && repo.description!.isNotEmpty)
                        Text(
                          repo.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        const Text('No description'),
                      SizedBox(height: 4.h),
                      Text(
                        'Language: ${repo.language ?? "Unknown"} • Updated: ${repo.updatedAt != null ? "${repo.updatedAt!.year}-${repo.updatedAt!.month.toString().padLeft(2, '0')}-${repo.updatedAt!.day.toString().padLeft(2, '0')}" : "Unknown"}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('${repo.stargazersCount}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}