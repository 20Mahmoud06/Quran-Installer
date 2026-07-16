import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../domain/entities/reciter.dart';
import '../../domain/repositories/reciters_repository.dart';

class RecitersRepositoryImpl implements RecitersRepository {
  final Box _settingsBox;
  List<Reciter>? _cachedReciters;

  RecitersRepositoryImpl(this._settingsBox);

  @override
  Future<List<Reciter>> getReciters() async {
    if (_cachedReciters != null) {
      return _updateRecitersWithFavorites(_cachedReciters!);
    }

    try {
      final jsonString = await rootBundle.loadString('assets/json/clean_root_reciters.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      final reciters = jsonMap.entries.map((e) => Reciter(
        name: e.key,
        serverUrl: e.value.toString(),
      )).toList();

      reciters.sort((a, b) => a.name.compareTo(b.name));
      _cachedReciters = reciters;

      return _updateRecitersWithFavorites(reciters);
    } catch (e) {
      throw Exception('Failed to load reciters: $e');
    }
  }

  List<Reciter> _updateRecitersWithFavorites(List<Reciter> reciters) {
    final favorites = _settingsBox.get(HiveKeys.favoriteReciters, defaultValue: <String>[]) as List<dynamic>;
    final favList = favorites.cast<String>();

    final recents = _settingsBox.get(HiveKeys.recentReciters, defaultValue: <String>[]) as List<dynamic>;
    final recentList = recents.cast<String>();

    return reciters.map((r) {
      final isFav = favList.contains(r.name);
      DateTime? lastAccessed;
      if (recentList.contains(r.name)) {
        lastAccessed = DateTime.now().subtract(Duration(days: recentList.indexOf(r.name)));
      }
      return r.copyWith(isFavorite: isFav, lastAccessed: lastAccessed);
    }).toList();
  }

  @override
  Future<void> toggleFavorite(String reciterName) async {
    final favorites = _settingsBox.get(HiveKeys.favoriteReciters, defaultValue: <String>[]) as List<dynamic>;
    final favList = favorites.cast<String>().toList();

    if (favList.contains(reciterName)) {
      favList.remove(reciterName);
    } else {
      favList.add(reciterName);
    }

    await _settingsBox.put(HiveKeys.favoriteReciters, favList);
  }

  @override
  Future<void> addRecent(String reciterName) async {
    final recents = _settingsBox.get(HiveKeys.recentReciters, defaultValue: <String>[]) as List<dynamic>;
    final recentList = recents.cast<String>().toList();

    recentList.remove(reciterName);
    recentList.insert(0, reciterName);

    if (recentList.length > 10) {
      recentList.removeLast();
    }

    await _settingsBox.put(HiveKeys.recentReciters, recentList);
  }

  @override
  Future<List<String>> getFavorites() async {
    final favorites = _settingsBox.get(HiveKeys.favoriteReciters, defaultValue: <String>[]) as List<dynamic>;
    return favorites.cast<String>();
  }

  @override
  Future<List<String>> getRecents() async {
    final recents = _settingsBox.get(HiveKeys.recentReciters, defaultValue: <String>[]) as List<dynamic>;
    return recents.cast<String>();
  }
}
