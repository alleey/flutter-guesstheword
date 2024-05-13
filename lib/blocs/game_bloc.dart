
import 'dart:developer';
import 'dart:math' as math;

import 'package:bit_array/bit_array.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guess_the_word/services/app_data_service.dart';

import '../common/constants.dart';
import '../main.dart';
import '../models/puzzle.dart';
import '../models/score.dart';
import '../services/puzzle_service.dart';
import '../services/score_service.dart';

////////////////////////////////////////////

abstract class GameBlocEvent {}

class ResetGameEvent extends GameBlocEvent {}

class StartPuzzleEvent extends GameBlocEvent {
  final bool forceNext;
  StartPuzzleEvent({this.forceNext = false});
}

class RequestHintEvent extends GameBlocEvent {
  final bool userInitiated;
  RequestHintEvent({this.userInitiated = false});
}

class UserInputEvent extends GameBlocEvent {
  final String symbol;
  final bool hintRequest;
  UserInputEvent(this.symbol, { this.hintRequest = false });
}

////////////////////////////////////////////

abstract class GameBlocState {}

class InitialGameState extends GameBlocState {}
class ResetState extends GameBlocState {}
class NoMorePuzzleState extends GameBlocState {}
class PuzzleStartState extends GameBlocState {}

class InputMatchState extends GameBlocState {}
class InputMismatchState extends GameBlocState {}

enum Difficulty {
  easy,
  medium,
  hard
}

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

  late int correctCount;
  late int errorCount;
  late int winBonus;
  late bool lastInputError;
  late Score score;

  bool get isWin => correctCount >= (value.length - whiteSpace.cardinality);
  bool get isLoss => errorCount >= Constants.maxErrors;
  bool get isGameOver => isWin || isLoss;
  bool get isHelpAvailable => score.hintTokens > 0;

  // Determine puzzle difficulty based on the number of non-whitespace characters
  Difficulty get difficulty => switch(value.length - whiteSpace.cardinality) {
    > Constants.difficultyMediumLen => Difficulty.hard,
    > Constants.difficultyEasyLen => Difficulty.medium,
    _ => Difficulty.easy,
  };

  void reset() {
    correctCount = 0;
    errorCount = 0;
    winBonus = 0;
    lastInputError = false;
    used = BitArray(symbolSet.length);
    revealed = BitArray(value.length);
    whiteSpace = BitArray(value.length);

    final valueLower = value.toLowerCase();
    for (var index in Iterable<int>.generate(valueLower.length)) {
      // symbols not in the symbolSet are revealed and displayed as WS
      var symbol = valueLower[index];
      if (!symbolSet.contains(symbol)) {
        revealed.setBit(index);
        whiteSpace.setBit(index);
      }
    }
  }

  List<String> randomReveal() {

    final histogram = <String,int>{};
    final valueLower = value.toLowerCase();

    for (var index in Iterable<int>.generate(valueLower.length)) {
      var symbol = valueLower[index];
      if (symbolSet.contains(symbol) && !revealed[index]) {
        if (!histogram.containsKey(symbol)) {
          histogram[symbol] = 0;
        }
        histogram[symbol] = histogram[symbol]! + 1;
      }
    }

    return leastUsedSymbols(histogram);
  }

  List<String> leastUsedSymbols(Map<String, int> histogram) {
    final en = histogram.entries.toList();
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

    used.setBit(symbolSet.indexOf(symbol));

    int index = -1;
    final valueLower = value.toLowerCase();
    do {
      index = valueLower.indexOf(symbol, index + 1);
      if (index >= 0) {
        revealed.setBit(index);
        correctCount ++;
      }
    }
    while(index > -1);
  }

  void error(String symbol) {
    used.setBit(symbolSet.indexOf(symbol));
    errorCount += 1;
  }

  bool update(String symbol, bool hintRequest) {

    if (isGameOver) {
      return false;
    }

    // if symbol already handled, return
    final symId = symbolSet.indexOf(symbol);
    if (used[symId]) {
      return false;
    }

    final valueLower = value.toLowerCase();
    lastInputError = !valueLower.contains(symbol);
    winBonus = 0;

    if (!lastInputError) {

      reveal(symbol);

      if (hintRequest) {
        score = score.consumeToken();
        log("consumed a hint token: ${score.hintTokens} remaining");
      }

      if (isWin) {
        // Calculate score based on length of puzzle and number of error
        // longer puzzles and fewer errors get more score
        winBonus = valueLower.length * (Constants.maxErrors - errorCount);
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
    log("score: $score");

    return true;
  }
}

////////////////////////////////////////////

class GameBloc extends Bloc<GameBlocEvent, GameBlocState>
{
  final appDataService = AppDataService(dataService: globalDataService);
  final puzzleService = PuzzleService(dataService: globalDataService);
  final scoreService = ScoreService(dataService: globalDataService);
  final random = math.Random();

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

      if (!canGoNext && !event.forceNext) {
        // Prevent against double clicks on GoNext
        return;
      }
      canGoNext = false;

      final p = await puzzleService.randomPuzzle();
      //final p = (-1, Puzzle(hint: "Famous Cartoon Character", value: "United Arab Emirates"));
      if (p == null) {
        emit(NoMorePuzzleState());
        return;
      }

      gameState = GameState(
        puzzleId: p.$1,
        hint: p.$2.hint,
        value: p.$2.value,
      );
      gameState.score = scoreService.get();
      //gameState.score = gameState.score.solved(500);

      log("score: ${gameState.score}");
      emit(PuzzleStartState());
      emit(GameState.clone(gameState));
    });

    on<UserInputEvent>((event, emit) async {

      if (gameState.update(event.symbol.toLowerCase(), event.hintRequest)) {

        await scoreService.put(gameState.score);
        if (gameState.isGameOver) {
          await puzzleService.delete(gameState.puzzleId);
          canGoNext = true;
        }

        log("score: ${gameState.score}");
        emit(gameState.lastInputError ? InputMismatchState() : InputMatchState());
        emit(GameState.clone(gameState));
      }
    });


    on<RequestHintEvent>((event, emit) async {

      final leastUsed = gameState.randomReveal();
      if (leastUsed.isEmpty) {
        return;
      }

      // This request hint was generated by a user action (helpline). In this case we fake a
      // user input to make sure the rest of the logic is triggered
      //
      if (event.userInitiated) {
        add(UserInputEvent(
          leastUsed[random.nextInt(leastUsed.length)],
          hintRequest: true
        ));
        return;
      }

      var reveal = switch(gameState.difficulty) {
          Difficulty.easy => Constants.revealEasy,
          Difficulty.medium => Constants.revealMedium,
          Difficulty.hard => Constants.revealHard,
        };

      for(var i =0; i < math.min(reveal, leastUsed.length); i++) {
        gameState.reveal(leastUsed[i]);
      }

      log("score: ${gameState.score}");
      emit(InputMatchState());
      emit(GameState.clone(gameState));
    });
  }
}
