
import 'dart:developer';
import 'dart:math' as math;

import 'package:bit_array/bit_array.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/constants.dart';
import '../common/histogram.dart';
import '../models/score.dart';
import '../services/app_data_service.dart';
import '../services/data_service.dart';
import '../services/puzzle_service.dart';
import '../services/score_service.dart';

////////////////////////////////////////////

abstract class GameBlocEvent {}

class InitializeGameEvent extends GameBlocEvent {}
class ResetGameEvent extends GameBlocEvent {}

class StartPuzzleEvent extends GameBlocEvent {
  final bool forceNext;
  StartPuzzleEvent({this.forceNext = false});
}

class RequestHintEvent extends GameBlocEvent {
  RequestHintEvent();
}

class UseHintTokenEvent extends GameBlocEvent {
  UseHintTokenEvent();
}

class UserInputEvent extends GameBlocEvent {
  final String symbol;
  final bool hintRequest;
  UserInputEvent(this.symbol, { this.hintRequest = false });
}

////////////////////////////////////////////

abstract class GameBlocState {}

class InitialGameState extends GameBlocState {}
class NoMorePuzzleState extends GameBlocState {}
class PuzzleStartState extends GameBlocState {}
class PuzzleCompleteState extends GameBlocState {
  final bool isWin;
  final int winBonus;
  final int hintBonus;
  PuzzleCompleteState({required this.isWin, required this.winBonus, required this.hintBonus});
}
class InputMatchState extends GameBlocState {
  final bool hintsChange;
  InputMatchState({required this.hintsChange});
}
class InputMismatchState extends GameBlocState {
  InputMismatchState();
}
class WaitState extends GameBlocState {
  final String message;
  WaitState({required this.message});
}

class ResetCompleteState extends GameBlocState {}
class ResetPendingState extends WaitState {
  ResetPendingState({required super.message});
}

class InitializeGameCompleteState extends GameBlocState {}

enum Difficulty {
  easy,
  medium,
  hard
}

class GameState extends GameBlocState {

  GameState({
    required this.puzzleId,
    required this.hint,
    required this.puzzle,
  }) {
    symbolSet = Constants.symbolSet.toLowerCase();
    reset();
  }

  factory GameState.clone(GameState other) {
    final p = GameState(
      puzzleId: other.puzzleId,
      hint: other.hint,
      puzzle: other.puzzle,
    );
    p.used = other.used;
    p.revealed = other.revealed;
    p.correctCount = other.correctCount;
    p.errorCount = other.errorCount;
    p.symbolSet = other.symbolSet;
    p.score = other.score;
    p.winBonus = other.winBonus;
    p.hintBonus = other.hintBonus;
    p.lastInputError = other.lastInputError;
    return p;
  }

  final int puzzleId;
  final String hint;
  final String puzzle;

  // All possible symbols
  late String symbolSet;
  // symbols tried so far
  late BitArray used;
  // symbols correctly matched so far
  late BitArray revealed;
  late BitArray whiteSpace;

  late Score score;
  late int correctCount;
  late int errorCount;
  late int winBonus;
  late int hintBonus;
  late bool lastInputError;

  bool get isWin => correctCount >= (puzzle.length - whiteSpace.cardinality);
  bool get isLoss => errorCount >= Constants.maxErrors;
  bool get isGameOver => isWin || isLoss;
  bool get isHelpAvailable => score.hintTokens > 0;
  bool get hasErrors => errorCount > 0;
  bool get hasCorrect => correctCount > 0;

  // Determine puzzle difficulty based on the number of non-whitespace characters
  Difficulty get difficulty => switch(puzzle.length - whiteSpace.cardinality) {
    > Constants.difficultyMediumLen => Difficulty.hard,
    > Constants.difficultyEasyLen => Difficulty.medium,
    _ => Difficulty.easy,
  };

  void reset() {
    correctCount = 0;
    errorCount = 0;
    winBonus = 0;
    hintBonus = 0;
    lastInputError = false;
    used = BitArray(symbolSet.length);
    revealed = BitArray(puzzle.length);
    whiteSpace = BitArray(puzzle.length);

    final valueLower = puzzle.toLowerCase();
    for (var index in Iterable<int>.generate(valueLower.length)) {
      // symbols not in the symbolSet are revealed and displayed as WS
      var symbol = valueLower[index];
      if (!symbolSet.contains(symbol)) {
        revealed.setBit(index);
        whiteSpace.setBit(index);
      }
    }
  }

  Histogram histogramOfUnrevealed() {

    final histogram = Histogram();
    final valueLower = puzzle.toLowerCase();

    Iterable<int>.generate(valueLower.length)
      .where((index) => symbolSet.contains(valueLower[index]) && !revealed[index])
      .map((index) => valueLower[index])
      .forEach((symbol) => histogram.add(symbol));

    return histogram;
  }

  void reveal(String symbol) {

    used.setBit(symbolSet.indexOf(symbol));

    int index = -1;
    final valueLower = puzzle.toLowerCase();
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

    final valueLower = puzzle.toLowerCase();
    var oldHints = score.hintTokens;

    lastInputError = !valueLower.contains(symbol);
    winBonus = 0;
    hintBonus = 0;

    if (!lastInputError) {

      reveal(symbol);

      if (hintRequest) {
        score = score.consumeToken();
        oldHints = score.hintTokens;
        log("consumed a hint token: ${score.hintTokens} remaining");
      }

      if (isWin) {
        // Calculate score based on length of puzzle and number of error
        // longer puzzles and fewer errors get more score
        winBonus = valueLower.length * (Constants.maxErrors - errorCount);
        score = score.bump(winBonus);
      }

      hintBonus = (score.hintTokens - oldHints);
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
    log("winBonus: $winBonus");
    log("hintBonus: $hintBonus");

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
    on<InitializeGameEvent>((event, emit) async {

      await puzzleService.importAll();
      emit(InitializeGameCompleteState());
    });

    on<ResetGameEvent>((event, emit) async {

      emit(ResetPendingState(message: "Please wait while the game is reset"));

      await appDataService.resetData();
      await puzzleService.resetData();
      await scoreService.resetData();
      canGoNext = true;

      emit(ResetCompleteState());
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
        puzzle: p.$2.value,
      );
      gameState.score = scoreService.get();
      //gameState.score = gameState.score.bump(5000);

      log("score: ${gameState.score}");
      emit(PuzzleStartState());
      emit(GameState.clone(gameState));
    });

    on<UserInputEvent>((event, emit) async {

      if (gameState.update(event.symbol.toLowerCase(), event.hintRequest)) {

        await scoreService.put(gameState.score);
        if (gameState.isGameOver) {
          await puzzleService.delete(gameState.puzzleId);
        }
        canGoNext = gameState.isGameOver;

        log("score: ${gameState.score}");
        if (gameState.isGameOver) {
          emit(PuzzleCompleteState(isWin: gameState.isWin, winBonus: gameState.winBonus, hintBonus: gameState.hintBonus));
        } else {
          emit(gameState.lastInputError ? InputMismatchState() : InputMatchState(hintsChange: gameState.hintBonus != 0));
        }
        emit(GameState.clone(gameState));
      }
    });

    on<RequestHintEvent>((event, emit) async {

      final histogram = gameState.histogramOfUnrevealed();
      if (histogram.isEmpty) {
        return;
      }

      var reveal = switch(gameState.difficulty) {
        Difficulty.easy => Constants.revealEasy,
        Difficulty.medium => Constants.revealMedium,
        Difficulty.hard => Constants.revealHard,
      };

      final leastOccuring = histogram.keysLeastOrder();
      for(var i =0; i < math.min(reveal, leastOccuring.length); i++) {
        gameState.reveal(leastOccuring[i]);
      }
      canGoNext = gameState.isGameOver;

      log("score: ${gameState.score}");
      if (gameState.isGameOver) {
        emit(PuzzleCompleteState(isWin: gameState.isWin, winBonus: gameState.winBonus, hintBonus: gameState.hintBonus));
      } else {
        emit(InputMatchState(hintsChange: gameState.hintBonus != 0));
      }
      emit(GameState.clone(gameState));
    });


    on<UseHintTokenEvent>((event, emit) async {

      final histogram = gameState.histogramOfUnrevealed();
      if (histogram.isEmpty) {
        return;
      }

      // This request hint was generated by a user action (helpline). In this case we fake a
      // user input to make sure the rest of the logic is triggered
      //
      add(UserInputEvent(
        histogram.keys.toList()[random.nextInt(histogram.length)],
        hintRequest: true
      ));
    });
  }
}
