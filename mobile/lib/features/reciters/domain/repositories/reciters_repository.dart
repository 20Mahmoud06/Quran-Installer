import '../entities/reciter.dart';

abstract class RecitersRepository {
  Future<List<Reciter>> getReciters();
  Future<void> toggleFavorite(String reciterName);
  Future<void> addRecent(String reciterName);
  Future<List<String>> getFavorites();
  Future<List<String>> getRecents();
}
