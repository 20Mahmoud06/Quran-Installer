import 'package:equatable/equatable.dart';
import '../domain/entities/reciter.dart';

abstract class RecitersState extends Equatable {
  const RecitersState();
  
  @override
  List<Object> get props => [];
}

class RecitersInitial extends RecitersState {}

class RecitersLoading extends RecitersState {}

class RecitersLoaded extends RecitersState {
  final List<Reciter> allReciters;
  final List<Reciter> filteredReciters;
  final String searchQuery;

  const RecitersLoaded({
    required this.allReciters,
    required this.filteredReciters,
    this.searchQuery = '',
  });

  RecitersLoaded copyWith({
    List<Reciter>? allReciters,
    List<Reciter>? filteredReciters,
    String? searchQuery,
  }) {
    return RecitersLoaded(
      allReciters: allReciters ?? this.allReciters,
      filteredReciters: filteredReciters ?? this.filteredReciters,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object> get props => [allReciters, filteredReciters, searchQuery];
}

class RecitersError extends RecitersState {
  final String message;

  const RecitersError(this.message);

  @override
  List<Object> get props => [message];
}
