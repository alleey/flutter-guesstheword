import 'package:flutter_test/flutter_test.dart';
import 'package:guess_the_word/blocs/game_bloc.dart';


void main() {
  testGameState();
}

void testGameState() {
  group('GameState', () {

    test("Histogram is correctly calculated", () {
      // arrange
      final state = GameState(puzzleId: 0, hint: "", puzzle: "aaaabbbccdef");

      // act
      final histogram = state.histogramOfUnrevealed();

      //assert
      expect(histogram, hasLength(6));
      expect(histogram.value['a'], 4);
      expect(histogram.value['c'], 2);
      expect(histogram.value['e'], 1);
    });
  });

  test("keys order is correctly calculated", () {
    // arrange
    final state = GameState(puzzleId: 0, hint: "", puzzle: "aaaabbbccdef");
    final histogram = state.histogramOfUnrevealed();

    // act
    final leastList = histogram.keysLeastOrder();

    //assert
    expect(leastList.getRange(0, 3), containsAll(['d', 'e', 'f']));
    expect(leastList[leastList.length - 1], 'a');
  });

}
