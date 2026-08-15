import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/github_user_controller.dart';
import '../controller/recent_searches_provider.dart';
import 'user_repositories.dart';
import '../../../models/github_user.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    FocusScope.of(context).unfocus();
    final text = _searchController.text.trim();
    if (text.isNotEmpty) {
      ref.read(searchUsernameProvider.notifier).state = text;
      ref.read(recentSearchesProvider.notifier).addSearch(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(githubUserFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Search',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical:10.h,horizontal: 16),
        child: Column(
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.lightBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.lightBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    prefixIcon: Icon(Icons.search, size: 20.sp, color: Colors.grey),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18.sp, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _onSearch(),
                );
              },
            ),
            SizedBox(height: 16.h),
            Consumer(
              builder: (context, ref, child) {
                final recentSearches = ref.watch(recentSearchesProvider);
                if (recentSearches.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Searches:', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            ref.read(recentSearchesProvider.notifier).clearSearches();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Clear All', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: recentSearches.map((search) {
                        return ActionChip(
                          label: Text(search),
                          onPressed: () {
                            ref.read(searchUsernameProvider.notifier).state = search;
                            ref.read(recentSearchesProvider.notifier).addSearch(search);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const Home()),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: userState.when(
                data: (user) {
                  if (user == null) {
                    return const Center(child: Text('Search for a GitHub user.'));
                  }
                  return _buildUserResult(user);
                },
                error: (error, stack) {
                  return Center(
                    child: Text(
                      error.toString().replaceAll('Exception: ', ''),
                      style: TextStyle(color: Colors.red, fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserResult(GithubUser user) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      },
      child: SingleChildScrollView(
        child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundImage: NetworkImage(user.avatarUrl),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 16.h),
          if (user.name != null)
            Text(
              user.name!,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          Text(
            '@${user.login}',
            style: TextStyle(fontSize: 18.sp, color: Colors.blueAccent),
          ),
          SizedBox(height: 16.h),
          if (user.bio != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Followers', user.followers),
              _buildStatColumn('Following', user.following),
              _buildStatColumn('Public Repos', user.publicRepos),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
