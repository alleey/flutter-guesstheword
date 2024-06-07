import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_word/models/statistics.dart';

void main() {
  group('Statistics', () {
    test('Test update method', () {
      // Create a sample Statistics object
      final stats = Statistics(
        wins: 5,
        losses: 3,
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
      expect(updatedStats.wins, 6);
      expect(updatedStats.losses, 3);
      expect(updatedStats.correctInputs, 30);
      expect(updatedStats.mismatchedInputs, 7);
      expect(updatedStats.hintsUsed, 3);
    });

    test('Test accuracy calculation', () {
      // Create a sample Statistics object
      final stats = Statistics(
        wins: 5,
        losses: 3,
        correctInputs: 20,
        mismatchedInputs: 5,
        hintsUsed: 2,
      );

      // Verify accuracy calculation
      expect(stats.accuracy, (20 - 2) / (20 + 5));
    });
  });

  group('StatisticsMap', () {

    test('Test getCategoriesSortedByWinRate method', () {
      // Create a sample StatisticsMap object
      final statsMap = CategoryStatistics(
        statisticsMap: {
          'category1': Statistics(wins: 5, losses: 5),
          'category2': Statistics(wins: 3, losses: 0),
          'category3': Statistics(wins: 4, losses: 2),
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
      final statsMap = CategoryStatistics(
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
