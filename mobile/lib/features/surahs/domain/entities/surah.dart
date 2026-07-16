import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int number;
  final String nameArabic;

  const Surah({
    required this.number,
    required this.nameArabic,
  });

  @override
  List<Object?> get props => [number, nameArabic];
}
