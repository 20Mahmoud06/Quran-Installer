import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/surahs_repository.dart';

class SurahsRepositoryImpl implements SurahsRepository {
  List<Surah>? _cachedSurahs;

  @override
  Future<List<Surah>> getSurahs() async {
    if (_cachedSurahs != null) {
      return _cachedSurahs!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/json/surah.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final surahs = <Surah>[];
      for (int i = 0; i < jsonList.length; i++) {
        surahs.add(Surah(
          number: i + 1,
          nameArabic: jsonList[i].toString(),
        ));
      }

      _cachedSurahs = surahs;
      return surahs;
    } catch (e) {
      throw Exception('Failed to load surahs: $e');
    }
  }
}
