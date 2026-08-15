import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]) {
    _loadSearches();
  }

  static const _key = 'recent_searches';

  Future<void> _loadSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_key) ?? [];
    state = searches;
  }

  Future<void> addSearch(String username) async {
    if (username.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_key) ?? [];
    
    // Remove if exists to move it to the top
    searches.remove(username);
    
    // Add to the top
    searches.insert(0, username);
    
    // Keep only last 5
    if (searches.length > 5) {
      searches = searches.sublist(0, 5);
    }
    
    await prefs.setStringList(_key, searches);
    state = searches;
  }

  Future<void> clearSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = [];
  }
}
