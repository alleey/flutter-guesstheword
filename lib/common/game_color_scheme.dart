import 'package:flutter/material.dart';
import 'package:guess_the_word/widgets/symbol_pad.dart';

sealed class GameColorSchemes {

  static const String defaultThemeName = "default";

  static final Map<String, GameColorScheme> _schemes = {
    defaultThemeName: GameColorScheme.defaultScheme(),
    "test1": GameColorScheme.test1(),
    "test12": GameColorScheme.test2(),
  };

  static Iterable<MapEntry<String, GameColorScheme>> get all => _schemes.entries;
  static GameColorScheme scheme(String? name) =>
    _schemes.containsKey(name ?? defaultThemeName) ? _schemes[name]! : GameColorScheme.defaultScheme();
}

class GameColorScheme {
  final Color backgroundTopPanel;
  final Color backgroundPuzzlePanel;
  final Color backgroundInputPanel;

  final Color textTopPanel;
  final Color textTopButton;
  final Color backgroundTopButton;
  final Color textHintButton;
  final Color backgroundHintButton;

  final Color colorIcons;
  final Color colorSuccess;
  final Color colorFailure;
  final Color colorHeart;
  final Color colorHeartBroken;

  final Color textPuzzlePanel;
  final Color textPuzzleSymbols;
  final Color textPuzzleSymbolsFlipped;
  final Color backgroundPuzzleSymbols;
  final Color backgroundPuzzleSymbolsFlipped;

  final Color textInputPanel;
  final Color textInputSymbols;
  final Color textInputSymbolsFlipped;
  final Color backgroundInputSymbols;
  final Color backgroundInputSymbolsFlipped;
  final Color textInputButton;
  final Color backgroundInputButton;

  GameColorScheme({
    required this.backgroundTopPanel,
    required this.backgroundPuzzlePanel,
    required this.backgroundInputPanel,

    this.textTopPanel = Colors.white,
    this.textTopButton = Colors.white,
    this.backgroundTopButton = Colors.black,
    this.textHintButton = Colors.black,
    this.backgroundHintButton = Colors.white,

    this.colorIcons = Colors.yellow,
    this.colorSuccess = Colors.green,
    this.colorFailure = Colors.red,
    this.colorHeart = Colors.red,
    this.colorHeartBroken = Colors.amber,

    this.textPuzzlePanel = Colors.white,
    this.textPuzzleSymbols = SymbolPad.defaultColorForeground,
    this.textPuzzleSymbolsFlipped = SymbolPad.defaultColorBackground,
    this.backgroundPuzzleSymbols = SymbolPad.defaultColorBackground,
    this.backgroundPuzzleSymbolsFlipped = SymbolPad.defaultColorForeground,

    this.textInputPanel = Colors.white,
    this.textInputSymbols = SymbolPad.defaultColorForeground,
    this.textInputSymbolsFlipped = SymbolPad.defaultColorBackground,
    this.backgroundInputSymbols = SymbolPad.defaultColorBackground,
    this.backgroundInputSymbolsFlipped = SymbolPad.defaultColorForeground,
    this.textInputButton = Colors.white,
    this.backgroundInputButton = Colors.black,
  });

  factory GameColorScheme.defaultScheme() => GameColorScheme(

    backgroundTopPanel: Colors.green.shade700,
    backgroundPuzzlePanel: Colors.red.shade600,
    backgroundInputPanel: Colors.blue.shade600,

    textTopPanel: Colors.white,
    backgroundTopButton: Colors.green.shade900,
    textHintButton: Colors.white,
    backgroundHintButton: Colors.green.shade700,

    colorIcons: Colors.yellow,
    colorSuccess: const Color.fromARGB(255, 8, 254, 16),
    colorFailure: Colors.redAccent,
    colorHeart: Colors.yellow,
    colorHeartBroken: Colors.black,

    textPuzzlePanel: Colors.white,
    textPuzzleSymbols: SymbolPad.defaultColorForeground,
    textPuzzleSymbolsFlipped: SymbolPad.defaultColorBackground,
    backgroundPuzzleSymbols: SymbolPad.defaultColorBackground,
    backgroundPuzzleSymbolsFlipped: Colors.white,

    textInputPanel: Colors.white,
    textInputSymbols: Colors.black,
    textInputSymbolsFlipped: Colors.white,
    backgroundInputSymbols: SymbolPad.defaultColorForeground,
    backgroundInputSymbolsFlipped: Colors.blue.shade600,
    backgroundInputButton: Colors.blue.shade900,
  );


  factory GameColorScheme.test1() {

    var color1 = _fromHex("151515");
    var color2 = _fromHex("A91D3A");
    var color3 = _fromHex("C73659");
    var color4 = _fromHex("EEEEEE");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color4,
      backgroundTopButton: color1,
      textHintButton: color4,
      backgroundHintButton: color1,

      colorIcons: Colors.yellow,
      colorSuccess: const Color.fromARGB(255, 8, 254, 16),
      colorFailure: Colors.redAccent,
      colorHeart: Colors.yellow,
      colorHeartBroken: color4,

      textPuzzlePanel: color4,
      textPuzzleSymbols: color4,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color1,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: color4,
      textInputSymbols: color4,
      backgroundInputSymbols: color1,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbolsFlipped: color4,
      backgroundInputButton: color1,
    );
  }

  factory GameColorScheme.test2() {

    var color1 = _fromHex("F5DAD2");
    var color2 = _fromHex("FCFFE0");
    var color3 = _fromHex("BACD92");
    var color4 = _fromHex("75A47F");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color4,
      backgroundTopButton: Colors.black,
      textHintButton: color4,
      backgroundHintButton: color1,

      colorIcons: Colors.redAccent,
      colorSuccess: color4,
      colorFailure: Colors.redAccent,
      colorHeart: Colors.redAccent,
      colorHeartBroken: color4,

      textPuzzlePanel: color4,
      textPuzzleSymbols: color2,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color3,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: color4,
      textInputSymbols: color4,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbols: color2,
      backgroundInputSymbolsFlipped: color4,
      backgroundInputButton: Colors.black,
    );
  }

  static Color _fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff$hex' : hex;
    return Color(int.parse(hex, radix: 16));
  }
}
