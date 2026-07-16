import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/text_utils.dart';
import '../domain/entities/surah.dart';
import '../domain/repositories/surahs_repository.dart';
import 'surahs_state.dart';

export 'surahs_state.dart';
export '../domain/entities/surah.dart';

class SurahsCubit extends Cubit<SurahsState> {
  final SurahsRepository repository;

  SurahsCubit(this.repository) : super(SurahsInitial());

  Future<void> loadSurahs() async {
    emit(SurahsLoading());
    try {
      final surahs = await repository.getSurahs();
      emit(SurahsLoaded(
        allSurahs: surahs,
        filteredSurahs: surahs,
        selectedSurahs: const [],
      ));
    } catch (e) {
      emit(SurahsError(e.toString()));
    }
  }

  void search(String query) {
    if (state is! SurahsLoaded) return;
    
    final currentState = state as SurahsLoaded;
    final all = currentState.allSurahs;

    if (query.isEmpty) {
      emit(currentState.copyWith(filteredSurahs: all, searchQuery: ''));
      return;
    }

    final normalizedQuery = TextUtils.normalizeArabicText(query);
    final transliteratedQuery = TextUtils.transliterateArabic(normalizedQuery);

    final filtered = all.where((surah) {
      final normalizedName = TextUtils.normalizeArabicText(surah.nameArabic);
      final transliteratedName = TextUtils.transliterateArabic(normalizedName);

      return normalizedName.contains(normalizedQuery) ||
             transliteratedName.contains(transliteratedQuery) ||
             normalizedName.startsWith(normalizedQuery) ||
             transliteratedName.startsWith(transliteratedQuery);
    }).toList();

    emit(currentState.copyWith(filteredSurahs: filtered, searchQuery: query));
  }

  void toggleSurahSelection(Surah surah) {
    if (state is! SurahsLoaded) return;
    final currentState = state as SurahsLoaded;
    
    final selected = List<Surah>.from(currentState.selectedSurahs);
    if (selected.contains(surah)) {
      selected.remove(surah);
    } else {
      selected.add(surah);
    }
    
    emit(currentState.copyWith(selectedSurahs: selected));
  }

  void selectAllSurahs() {
    if (state is! SurahsLoaded) return;
    final currentState = state as SurahsLoaded;
    emit(currentState.copyWith(selectedSurahs: List.from(currentState.allSurahs)));
  }

  void clearSelection() {
    if (state is! SurahsLoaded) return;
    final currentState = state as SurahsLoaded;
    emit(currentState.copyWith(selectedSurahs: const []));
  }
}
