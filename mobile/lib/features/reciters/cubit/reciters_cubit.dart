import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/text_utils.dart';
import '../domain/repositories/reciters_repository.dart';
import 'reciters_state.dart';

export 'reciters_state.dart';
export '../domain/entities/reciter.dart';

class RecitersCubit extends Cubit<RecitersState> {
  final RecitersRepository repository;

  RecitersCubit(this.repository) : super(RecitersInitial());

  Future<void> loadReciters() async {
    emit(RecitersLoading());
    try {
      final reciters = await repository.getReciters();
      emit(RecitersLoaded(
        allReciters: reciters,
        filteredReciters: reciters,
      ));
    } catch (e) {
      emit(RecitersError(e.toString()));
    }
  }

  void search(String query) {
    if (state is! RecitersLoaded) return;
    
    final currentState = state as RecitersLoaded;
    final all = currentState.allReciters;

    if (query.isEmpty) {
      emit(currentState.copyWith(filteredReciters: all, searchQuery: ''));
      return;
    }

    final normalizedQuery = TextUtils.normalizeArabicText(query);
    final transliteratedQuery = TextUtils.transliterateArabic(normalizedQuery);

    final filtered = all.where((reciter) {
      final normalizedName = TextUtils.normalizeArabicText(reciter.name);
      final transliteratedName = TextUtils.transliterateArabic(normalizedName);

      return normalizedName.contains(normalizedQuery) ||
             transliteratedName.contains(transliteratedQuery) ||
             normalizedName.startsWith(normalizedQuery) ||
             transliteratedName.startsWith(transliteratedQuery);
    }).toList();

    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      
      final normA = TextUtils.normalizeArabicText(a.name);
      final normB = TextUtils.normalizeArabicText(b.name);

      final aStarts = normA.startsWith(normalizedQuery);
      final bStarts = normB.startsWith(normalizedQuery);

      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      return a.name.compareTo(b.name);
    });

    emit(currentState.copyWith(filteredReciters: filtered, searchQuery: query));
  }

  Future<void> toggleFavorite(String reciterName) async {
    if (state is! RecitersLoaded) return;
    try {
      await repository.toggleFavorite(reciterName);
      final reciters = await repository.getReciters();
      final currentState = state as RecitersLoaded;
      
      emit(currentState.copyWith(
        allReciters: reciters,
      ));
      search(currentState.searchQuery);
    } catch (e) {}
  }

  Future<void> addRecent(String reciterName) async {
    if (state is! RecitersLoaded) return;
    try {
      await repository.addRecent(reciterName);
      final reciters = await repository.getReciters();
      final currentState = state as RecitersLoaded;
      
      emit(currentState.copyWith(
        allReciters: reciters,
      ));
      search(currentState.searchQuery);
    } catch (e) {}
  }
}
