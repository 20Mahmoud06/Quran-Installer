import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  final String name;
  final String serverUrl;
  final bool isFavorite;
  final DateTime? lastAccessed;

  const Reciter({
    required this.name,
    required this.serverUrl,
    this.isFavorite = false,
    this.lastAccessed,
  });

  Reciter copyWith({
    String? name,
    String? serverUrl,
    bool? isFavorite,
    DateTime? lastAccessed,
  }) {
    return Reciter(
      name: name ?? this.name,
      serverUrl: serverUrl ?? this.serverUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  List<Object?> get props => [name, serverUrl, isFavorite, lastAccessed];
}
