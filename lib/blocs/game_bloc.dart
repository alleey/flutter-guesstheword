
import 'dart:developer';

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
    required this.hint,
    required this.value,
  }) {
    symbolSet = Constants.symbolSet.toLowerCase();
    reset();
  }

  factory GameState.clone(GameState other) {
    final p = GameState(
      hint: other.hint,
      value: other.value,
    );
    p.used = other.used;
    p.revealed = other.revealed;
    p.correctCount = other.correctCount;
    p.errorCount = other.errorCount;
    p.symbolSet = other.symbolSet;
    p.score = other.score;
    return p;
  }

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
  late bool lastInputError;
  late Score score;

  bool get isWin => correctCount >= value.length;
  bool get isLoss => errorCount >= Constants.maxErrors;
  bool get isGameOver => isWin || isLoss;

  void reset() {
    correctCount = 0;
    errorCount = 0;
    used = BitArray(symbolSet.length);
    revealed = BitArray(value.length);
    whiteSpace = BitArray(value.length);

    Iterable<int>.generate(value.length).forEach((index) {
      // symbols not in the symbolset are revealed and displayed as WS
      if (!symbolSet.contains(value[index])) {
        revealed.setBit(index);
        whiteSpace.setBit(index);
      }
    });
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

    lastInputError = !value.contains(symbol);

    if (!lastInputError) {

      reveal(symbol);
      if (isWin) {
        // Calculate score based on length of puzzle and number of error
        // longer puzzles and fewer errors get more score
        int val = value.length * (Constants.maxErrors - errorCount);
        score = score.solved(val);
      }
    } else {

      error(symbol);
      if (isLoss) {
        revealed.setAll();
        score = score.failed();
      }
    }

    log("revealed: ${revealed.toBinaryString()}");
    log("correct: ${correctCount}");
    log("errors: ${errorCount}");

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

  GameBloc() : super(InitialGameState())
  {
    on<ResetGameEvent>((event, emit) async {

      await appDataService.resetData();
      await puzzleService.resetData();
      await scoreService.resetData();
      emit(ResetState());
    });

    on<StartPuzzleEvent>((event, emit) async {
      
      final p = await puzzleService.popOne();
      if (p == null) {
        emit(NoMorePuzzleState());
        return;
      }

      gameState = GameState(
        hint: p.hint,
        value: p.value.toLowerCase(),
      );
      gameState.score = scoreService.get();

      emit(PuzzleStartState());
      emit(GameState.clone(gameState));
    });

    on<UserInputEvent>((event, emit) async {

      if (gameState.update(event.symbol.toLowerCase())) {
        
        if (gameState.isGameOver) {
          await scoreService.put(gameState.score);
        }
        
        emit(gameState.lastInputError ? InputMismatchState() : InputMatchState());
        emit(GameState.clone(gameState));
      }
    });
  }
}
