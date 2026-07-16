import '../entities/surah.dart';

abstract class SurahsRepository {
  Future<List<Surah>> getSurahs();
}
