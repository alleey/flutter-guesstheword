
import 'dart:developer';
import 'dart:math' as math;

import 'package:bit_array/bit_array.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/constants.dart';
import '../common/histogram.dart';
import '../models/player_stats.dart';
import '../services/app_data_service.dart';
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
  final String messageKey;
  WaitState({required this.messageKey});
}

class ResetCompleteState extends GameBlocState {}
class ResetPendingState extends WaitState {
  ResetPendingState({required super.messageKey});
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
    p.playerStats = other.playerStats;
    p.sessionStats = other.sessionStats;
    p.winBonus = other.winBonus;
    p.hintBonus = other.hintBonus;
    p.hintUsed = other.hintUsed;
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

  late PlayerStatistics playerStats;
  late PlayerStatistics sessionStats;
  late int correctCount;
  late int errorCount;
  late int winBonus;
  late int hintBonus;
  late int hintUsed;
  late bool lastInputError;

  bool get isWin => correctCount >= (puzzle.length - whiteSpace.cardinality);
  bool get isLoss => errorCount >= Constants.maxErrors;
  bool get isGameOver => isWin || isLoss;
  bool get isHelpAvailable => playerStats.hintTokens > 0;
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
    hintUsed = 0;
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

  int reveal(String symbol) {

    int revealCount = 0;
    used.setBit(symbolSet.indexOf(symbol));

    int index = -1;
    final valueLower = puzzle.toLowerCase();
    do {
      index = valueLower.indexOf(symbol, index + 1);
      if (index >= 0) {
        revealed.setBit(index);
        correctCount ++;
        revealCount ++;
      }
    }
    while(index > -1);

    return revealCount;
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
    var oldHints = playerStats.hintTokens;

    lastInputError = !valueLower.contains(symbol);
    winBonus = 0;
    hintBonus = 0;

    if (!lastInputError) {

      reveal(symbol);

      if (hintRequest) {
        playerStats = playerStats.consumeToken();
        oldHints = playerStats.hintTokens;
        hintUsed ++;
        log("consumed a hint token: ${playerStats.hintTokens} remaining");
      }

      if (isWin) {
        // Calculate score based on length of puzzle and number of error
        // longer puzzles and fewer errors get more score
        winBonus = valueLower.length * (Constants.maxErrors - errorCount);
        playerStats = playerStats.bump(winBonus);
        sessionStats = sessionStats.bump(winBonus);
      }

      hintBonus = (playerStats.hintTokens - oldHints);
    } else {

      error(symbol);
      if (isLoss) {
        revealed.setAll();
      }
    }

    if (isGameOver) {
      playerStats = playerStats.updateStats(
        category: hint,
        win: isWin,
        correctInputs: correctCount,
        mismatchedInputs: errorCount,
        hintsUsed: hintUsed
      );
      sessionStats = sessionStats.updateStats(
        category: hint,
        win: isWin,
        correctInputs: correctCount,
        mismatchedInputs: errorCount,
        hintsUsed: hintUsed
      );
    }

    log("revealed: ${revealed.toBinaryString()}");
    log("correct: $correctCount");
    log("errors: $errorCount");
    log("playerStats: $playerStats");
    log("sessionStats: $sessionStats");
    log("winBonus: $winBonus");
    log("hintBonus: $hintBonus");

    return true;
  }
}

////////////////////////////////////////////

class GameBloc extends Bloc<GameBlocEvent, GameBlocState>
{
  final _appDataService = AppDataService();
  final _puzzleService = PuzzleService();
  final _scoreService = ScoreService();
  final _random = math.Random();

  GameState? _gameState;
  bool _canGoNext = true;

  GameBloc() : super(InitialGameState())
  {
    on<InitializeGameEvent>((event, emit) async {

      await _puzzleService.importAll();
      emit(InitializeGameCompleteState());
    });

    on<ResetGameEvent>((event, emit) async {

      emit(ResetPendingState(messageKey: "dlg_popup_wait_reset"));

      final newInstanceId = await _appDataService.resetData();
      await _puzzleService.resetData(newInstanceId);
      await _scoreService.resetData(newInstanceId);

      _canGoNext = true;

      emit(ResetCompleteState());
    });

    on<StartPuzzleEvent>((event, emit) async {

      if (!_canGoNext && !event.forceNext) {
        // Prevent against double clicks on GoNext
        return;
      }
      _canGoNext = false;

      final p = await _puzzleService.randomPuzzle();
      //final p = (-1, Puzzle(hint: "Famous Cartoon Character", value: "United Arab Emirates"));
      if (p == null) {
        emit(NoMorePuzzleState());
        return;
      }

      final previousGameStats = _gameState?.sessionStats;

      _gameState = GameState(
        puzzleId: p.$1,
        hint: p.$2.hint,
        puzzle: p.$2.value,
      );

      final state = _ensureGameState();
      state.playerStats = _scoreService.load();
      state.sessionStats = previousGameStats ?? PlayerStatistics(hintTokens: state.playerStats.hintTokens);

      // debug mode
      state.playerStats = state.playerStats.grantTokens(100);

      log("score: ${state.playerStats}");
      emit(PuzzleStartState());
      emit(GameState.clone(state));
    });

    on<UserInputEvent>((event, emit) async {

      final state = _ensureGameState();

      if (state.update(event.symbol.toLowerCase(), event.hintRequest)) {

        await _scoreService.save(state.playerStats);
        if (state.isGameOver) {
          await _puzzleService.delete(state.puzzleId);
        }
        _canGoNext = state.isGameOver;

        log("score: ${state.playerStats}");
        if (state.isGameOver) {
          emit(PuzzleCompleteState(isWin: state.isWin, winBonus: state.winBonus, hintBonus: state.hintBonus));
        } else {
          emit(state.lastInputError ? InputMismatchState() : InputMatchState(hintsChange: state.hintBonus != 0));
        }
        emit(GameState.clone(state));
      }
    });

    on<RequestHintEvent>((event, emit) async {

      final state = _ensureGameState();
      final histogram = state.histogramOfUnrevealed();
      if (histogram.isEmpty) {
        return;
      }

      var reveal = switch(state.difficulty) {
        Difficulty.easy => Constants.revealEasy,
        Difficulty.medium => Constants.revealMedium,
        Difficulty.hard => Constants.revealHard,
      };

      final leastOccuring = histogram.keysLeastOrder();
      int revealed = 0;
      for(var i =0; i < math.min(reveal, leastOccuring.length); i++) {
        revealed += state.reveal(leastOccuring[i]);
      }

      log("score: ${state.playerStats}");

      if (revealed > 0) {
        emit(InputMatchState(hintsChange: state.hintBonus != 0));
        emit(GameState.clone(state));
      }
    });


    on<UseHintTokenEvent>((event, emit) async {

      final state = _ensureGameState();
      final histogram = state.histogramOfUnrevealed();
      if (histogram.isEmpty) {
        return;
      }

      // This request hint was generated by a user action (helpline). In this case we fake a
      // user input to make sure the rest of the logic is triggered
      //
      add(UserInputEvent(
        histogram.keys.toList()[_random.nextInt(histogram.length)],
        hintRequest: true
      ));
    });
  }

  GameState _ensureGameState() {
      if (_gameState == null) throw Exception("GameState is null");
      return _gameState!;
  }
}

extension GameBlocContextExtensions on BuildContext {
  GameBloc get gameBloc => BlocProvider.of<GameBloc>(this);
}
