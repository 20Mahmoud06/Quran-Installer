import 'package:equatable/equatable.dart';
import '../domain/entities/surah.dart';

abstract class SurahsState extends Equatable {
  const SurahsState();
  
  @override
  List<Object> get props => [];
}

class SurahsInitial extends SurahsState {}

class SurahsLoading extends SurahsState {}

class SurahsLoaded extends SurahsState {
  final List<Surah> allSurahs;
  final List<Surah> filteredSurahs;
  final List<Surah> selectedSurahs;
  final String searchQuery;

  const SurahsLoaded({
    required this.allSurahs,
    required this.filteredSurahs,
    required this.selectedSurahs,
    this.searchQuery = '',
  });

  SurahsLoaded copyWith({
    List<Surah>? allSurahs,
    List<Surah>? filteredSurahs,
    List<Surah>? selectedSurahs,
    String? searchQuery,
  }) {
    return SurahsLoaded(
      allSurahs: allSurahs ?? this.allSurahs,
      filteredSurahs: filteredSurahs ?? this.filteredSurahs,
      selectedSurahs: selectedSurahs ?? this.selectedSurahs,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [allSurahs, filteredSurahs, selectedSurahs, searchQuery];
}

class SurahsError extends SurahsState {
  final String message;

  const SurahsError(this.message);

  @override
  List<Object> get props => [message];
}
