
import 'dart:developer';
import 'dart:math' as math;

import 'package:bit_array/bit_array.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_word/services/app_data_service.dart';

import '../common/constants.dart';
import '../main.dart';
import '../models/score.dart';
import '../services/puzzle_service.dart';
import '../services/score_service.dart';

////////////////////////////////////////////

abstract class GameBlocEvent {}

class ResetGameEvent extends GameBlocEvent {}
class StartPuzzleEvent extends GameBlocEvent {}
class RequestHintEvent extends GameBlocEvent {}
class UserInputEvent extends GameBlocEvent {
  final String symbol;
  UserInputEvent(this.symbol);
}

////////////////////////////////////////////

abstract class GameBlocState {}

class InitialGameState extends GameBlocState {}
class ResetState extends GameBlocState {}
class NoMorePuzzleState extends GameBlocState {}
class PuzzleStartState extends GameBlocState {}

class InputMatchState extends GameBlocState {}
class InputMismatchState extends GameBlocState {}

class GameState extends GameBlocState {

  GameState({
    required this.puzzleId,
    required this.hint,
    required this.value,
  }) {
    symbolSet = Constants.symbolSet.toLowerCase();
    reset();
  }

  factory GameState.clone(GameState other) {
    final p = GameState(
      puzzleId: other.puzzleId,
      hint: other.hint,
      value: other.value,
    );
    p.used = other.used;
    p.revealed = other.revealed;
    p.correctCount = other.correctCount;
    p.errorCount = other.errorCount;
    p.symbolSet = other.symbolSet;
    p.score = other.score;
    p.winBonus = other.winBonus;
    p.lastInputError = other.lastInputError;
    return p;
  }

  final int puzzleId;
  final String hint;
  final String value;
  // All possible symbols
  late String symbolSet;
  // symbols tried so far
  late BitArray used;
  // symbols correctly matched so far
  late BitArray revealed;
  late BitArray whiteSpace;
  // symbols unmatched
  late int correctCount;
  late int errorCount;
  late int winBonus;
  late bool lastInputError;
  late Score score;

  bool get isWin => correctCount >= (value.length - whiteSpace.cardinality);
  bool get isLoss => errorCount >= Constants.maxErrors;
  bool get isGameOver => isWin || isLoss;

  void reset() {
    correctCount = 0;
    errorCount = 0;
    winBonus = 0;
    lastInputError = false;
    used = BitArray(symbolSet.length);
    revealed = BitArray(value.length);
    whiteSpace = BitArray(value.length);

    for (var index in Iterable<int>.generate(value.length)) {
      // symbols not in the symbolSet are revealed and displayed as WS
      var symbol = value[index];
      if (!symbolSet.contains(symbol)) {
        revealed.setBit(index);
        whiteSpace.setBit(index);
      }
    }
  }

  List<String> randomReveal() {

    final histogram = <String,int>{};
    for (var index in Iterable<int>.generate(value.length)) {
      var symbol = value[index];
      if (symbolSet.contains(symbol) && !revealed[index]) {
        if (!histogram.containsKey(symbol)) {
          histogram[symbol] = 0;
        }
        histogram[symbol] = histogram[symbol]! + 1;
      }
    }
    return leastUsedSymbols(histogram);
  }

  List<String> leastUsedSymbols(Map<String, int> leastUsed) {
    final en = leastUsed.entries.toList();
    en.sort((a,b)  {
      return a.value.compareTo(b.value);
    });
    final least = en
        .where((e) => e.value == en[0].value)
        .map((e) => e.key)
        .toList();
    least.shuffle();
    return least;
  }

  void reveal(String symbol) {

    int index = -1;
    do {
      index = value.indexOf(symbol, index + 1);
      if (index >= 0) {
        revealed.setBit(index);
        correctCount ++;
      }
    }
    while(index > -1);
    used.setBit(symbolSet.indexOf(symbol));
  }

  void error(String symbol) {
    used.setBit(symbolSet.indexOf(symbol));
    errorCount += 1;
  }

  bool update(String symbol) {

    if (isGameOver) {
      return false;
    }

    // if symbol already handled, return
    final symId = symbolSet.indexOf(symbol);
    if (used[symId]) {
      return false;
    }

    lastInputError = !value.contains(symbol);
    winBonus = 0;

    if (!lastInputError) {

      reveal(symbol);
      if (isWin) {
        // Calculate score based on length of puzzle and number of error
        // longer puzzles and fewer errors get more score
        winBonus = value.length * (Constants.maxErrors - errorCount);
        score = score.solved(winBonus);
      }
    } else {

      error(symbol);
      if (isLoss) {
        revealed.setAll();
        score = score.failed();
      }
    }

    log("revealed: ${revealed.toBinaryString()}");
    log("correct: $correctCount");
    log("errors: $errorCount");

    return true;
  }
}

////////////////////////////////////////////

class GameBloc extends Bloc<GameBlocEvent, GameBlocState>
{
  final appDataService = AppDataService(dataService: globalDataService);
  final puzzleService = PuzzleService(dataService: globalDataService);
  final scoreService = ScoreService(dataService: globalDataService);
  late GameState gameState;
  late bool canGoNext = true;

  GameBloc() : super(InitialGameState())
  {
    on<ResetGameEvent>((event, emit) async {

      await appDataService.resetData();
      await puzzleService.resetData();
      await scoreService.resetData();
      canGoNext = true;

      emit(ResetState());
    });

    on<StartPuzzleEvent>((event, emit) async {

      if (!canGoNext) {
        // Prevent against double clicks on GoNext
        return;
      }
      canGoNext = false;

      final p = await puzzleService.randomPuzzle();
      //final p = Puzzle(hint: "Famous Cartoon Character", value: "United Arab Emirates");
      if (p == null) {
        emit(NoMorePuzzleState());
        return;
      }

      gameState = GameState(
        puzzleId: p.$1,
        hint: p.$2.hint,
        value: p.$2.value.toLowerCase(),
      );
      gameState.score = scoreService.get();

      emit(PuzzleStartState());
      emit(GameState.clone(gameState));
    });

    on<UserInputEvent>((event, emit) async {

      if (gameState.update(event.symbol.toLowerCase())) {

        if (gameState.isGameOver) {
          await scoreService.put(gameState.score);
          await puzzleService.delete(gameState.puzzleId);
          canGoNext = true;
        }

        emit(gameState.lastInputError ? InputMismatchState() : InputMatchState());
        emit(GameState.clone(gameState));
      }
    });


    on<RequestHintEvent>((event, emit) async {

      final leastUsed = gameState.randomReveal();
      for(var i =0; i < math.min(Constants.maxInitialReveal, leastUsed.length); i++) {
        gameState.reveal(leastUsed[i]);
      }

      emit(InputMatchState());
      emit(GameState.clone(gameState));
    });
  }
}
