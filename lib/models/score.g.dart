// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreAdapter extends TypeAdapter<Score> {
  @override
  final int typeId = 1;

  @override
  Score read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Score(
      instance: fields[0] as int,
      value: fields[1] as int,
      wins: fields[2] as int,
      losses: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Score obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.instance)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.wins)
      ..writeByte(3)
      ..write(obj.losses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
