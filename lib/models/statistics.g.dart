// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
      totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      totalLosses: (json['totalLosses'] as num?)?.toInt() ?? 0,
      correctInputs: (json['correctInputs'] as num?)?.toInt() ?? 0,
      mismatchedInputs: (json['mismatchedInputs'] as num?)?.toInt() ?? 0,
      hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'totalWins': instance.totalWins,
      'totalLosses': instance.totalLosses,
      'correctInputs': instance.correctInputs,
      'mismatchedInputs': instance.mismatchedInputs,
      'hintsUsed': instance.hintsUsed,
    };

StatisticsCollection _$StatisticsCollectionFromJson(
        Map<String, dynamic> json) =>
    StatisticsCollection(
      instance: (json['instance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatisticsCollectionToJson(
        StatisticsCollection instance) =>
    <String, dynamic>{
      'instance': instance.instance,
    };
