
import 'package:hive/hive.dart';

part 'puzzle.g.dart';

@HiveType(typeId: 0)
class Puzzle {

  @HiveField(0)
  final String hint;
  @HiveField(1)
  final String value;

  Puzzle({ required this.hint, required this.value });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      value: json["value"].toString(),
      hint: json["hint"].toString(),
    );
  }
}

