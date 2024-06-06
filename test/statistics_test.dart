import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_word/models/statistics.dart';

void main() {
  group('Statistics', () {
    test('Test update method', () {
      // Create a sample Statistics object
      final stats = Statistics(
        totalWins: 5,
        totalLosses: 3,
        correctInputs: 20,
        mismatchedInputs: 5,
        hintsUsed: 2,
      );

      // Update the statistics
      final updatedStats = stats.update(
        win: true,
        correctInputs: 10,
        mismatchedInputs: 2,
        hintsUsed: 1,
      );

      // Verify the updated statistics
      expect(updatedStats.totalWins, 6);
      expect(updatedStats.totalLosses, 3);
      expect(updatedStats.correctInputs, 30);
      expect(updatedStats.mismatchedInputs, 7);
      expect(updatedStats.hintsUsed, 3);
    });

    test('Test accuracy calculation', () {
      // Create a sample Statistics object
      final stats = Statistics(
        totalWins: 5,
        totalLosses: 3,
        correctInputs: 20,
        mismatchedInputs: 5,
        hintsUsed: 2,
      );

      // Verify accuracy calculation
      expect(stats.accuracy, (20 - 2) / (20 + 5));
    });
  });

  group('StatisticsMap', () {
    test('Test getCategoryStatisticsExcludingOverall method', () {
      // Create a sample StatisticsMap object
      final statsMap = StatisticsCollection(
        statisticsMap: {
          'category1': Statistics(),
          'category2': Statistics(),
          'overall': Statistics(),
        },
      );

      // Get category statistics excluding overall
      final categoryStats = statsMap.getStatisticsExcludingOverall();

      // Verify category statistics
      expect(categoryStats.length, 2);
      expect(categoryStats.containsKey('overall'), false);
    });

    test('Test getCategoriesSortedByWinRate method', () {
      // Create a sample StatisticsMap object
      final statsMap = StatisticsCollection(
        statisticsMap: {
          'category1': Statistics(totalWins: 5, totalLosses: 5),
          'category2': Statistics(totalWins: 3, totalLosses: 0),
          'category3': Statistics(totalWins: 4, totalLosses: 2),
          'overall': Statistics(),
        },
      );

      // Get categories sorted by win rate
      final sortedCategoriesByWinRate = statsMap.sortedByWinRate;

      // Verify the sorted categories
      expect(sortedCategoriesByWinRate.map((entry) => entry.key), equals(['category2', 'category3', 'category1']));
    });

    test('Test getCategoriesSortedByAccuracy method', () {
      // Create a sample StatisticsMap object
      final statsMap = StatisticsCollection(
        statisticsMap: {
          'category1': Statistics(correctInputs: 20, mismatchedInputs: 5, hintsUsed: 0),
          'category2': Statistics(correctInputs: 20, mismatchedInputs: 7, hintsUsed: 0),
          'category3': Statistics(correctInputs: 20, mismatchedInputs: 8, hintsUsed: 0),
          'overall': Statistics(),
        },
      );

      // Get categories sorted by accuracy
      final sortedCategoriesByAccuracy = statsMap.sortedByAccuracy;

      // Verify the sorted categories
      expect(sortedCategoriesByAccuracy.map((entry) => entry.key), equals(['category1', 'category2', 'category3']));
    });

  });
}
