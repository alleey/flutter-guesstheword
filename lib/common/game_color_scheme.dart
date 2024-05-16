import 'package:flutter/material.dart';
import 'package:guess_the_word/widgets/symbol_pad.dart';

////////////////////////////////////////////

sealed class GameColorSchemes {

  static const String defaultThemeName = "default";

  static final Map<String, GameColorScheme> _schemes = {
    defaultThemeName: GameColorScheme.defaultScheme(),
    "1": GameColorScheme.theme1(),
    "2": GameColorScheme.theme2(),
    "3": GameColorScheme.theme3(),
    "4": GameColorScheme.theme4(),
    "5": GameColorScheme.theme5(),
    "6": GameColorScheme.theme6(),
    "7": GameColorScheme.theme7(),
  };

  static Iterable<MapEntry<String, GameColorScheme>> get all => _schemes.entries;
  static GameColorScheme scheme(String? name) =>
    _schemes.containsKey(name ?? defaultThemeName) ? _schemes[name]! : GameColorScheme.defaultScheme();
}

////////////////////////////////////////////

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

  factory GameColorScheme.defaultScheme() {

    var color1 = _fromHex("114232");
    var color2 = _fromHex("87a922");
    var color3 = _fromHex("fcdc2a");
    var color4 = _fromHex("f7f6bb");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color4,
      backgroundTopButton: color1,
      textHintButton: color1,
      backgroundHintButton: color4,

      colorIcons: Colors.yellow,
      colorSuccess: const Color.fromARGB(255, 8, 254, 16),
      colorFailure: Colors.redAccent,
      colorHeart: Colors.yellow,
      colorHeartBroken: color4,

      textPuzzlePanel: color1,
      textPuzzleSymbols: color4,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color1,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: color1,
      textInputSymbols: color4,
      backgroundInputSymbols: color1,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbolsFlipped: color4,
      backgroundInputButton: color1,
    );
  }

  factory GameColorScheme.theme1() {

    var color1 = _fromHex("151515");
    var color2 = _fromHex("a91d3a");
    var color3 = _fromHex("c73659");
    var color4 = _fromHex("eeeeee");

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

  factory GameColorScheme.theme2() {

    var color1 = _fromHex("f5dad2");
    var color2 = _fromHex("fcffe0");
    var color3 = _fromHex("bacd92");
    var color4 = _fromHex("75a47f");

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

  factory GameColorScheme.theme3() {

    var color1 = _fromHex("c40c0c");
    var color2 = _fromHex("ff6500");
    var color3 = _fromHex("ff8a08");
    var color4 = _fromHex("ffc100");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: Colors.white,
      textTopButton: Colors.white,
      backgroundTopButton: color2,
      textHintButton: Colors.white,
      backgroundHintButton: color3,

      colorIcons: Colors.yellow,
      colorSuccess: color4,
      colorFailure: Colors.white,
      colorHeart: Colors.yellow,
      colorHeartBroken: color4,

      textPuzzlePanel: Colors.white,
      textPuzzleSymbols: Colors.white,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color3,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: Colors.white,
      textInputSymbols: Colors.white,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbols: color2,
      backgroundInputSymbolsFlipped: color4,
      textInputButton: Colors.white,
      backgroundInputButton: color1,
    );
  }

  factory GameColorScheme.theme4() {

    var color1 = _fromHex("12372a");
    var color2 = _fromHex("436850");
    var color3 = _fromHex("adbc9f");
    var color4 = _fromHex("fbfada");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color4,
      backgroundTopButton: color1,
      textHintButton: color1,
      backgroundHintButton: color4,

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

      textInputPanel: color1,
      textInputSymbols: color4,
      backgroundInputSymbols: color1,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbolsFlipped: color4,
      backgroundInputButton: color1,
    );
  }

  factory GameColorScheme.theme5() {

    var color1 = _fromHex("f8f4ec");
    var color2 = _fromHex("ff9bd2");
    var color3 = _fromHex("d63484");
    var color4 = _fromHex("402b3a");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color4,
      textTopButton: Colors.white,
      backgroundTopButton: color2,
      textHintButton: Colors.white,
      backgroundHintButton: color3,

      colorIcons: color3,
      colorSuccess: color4,
      colorFailure: color4,
      colorHeart: color3,
      colorHeartBroken: color4,

      textPuzzlePanel: color3,
      textPuzzleSymbols: Colors.white,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color3,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: Colors.white,
      textInputSymbols: Colors.white,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbols: color2,
      backgroundInputSymbolsFlipped: color4,
      textInputButton: color4,
      backgroundInputButton: color1,
    );
  }

  factory GameColorScheme.theme6() {

    var color1 = _fromHex("dcf2f1");
    var color2 = _fromHex("7fc7d9");
    var color3 = _fromHex("365486");
    var color4 = _fromHex("0f1035");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color3,
      textTopButton: Colors.white,
      backgroundTopButton: color2,
      textHintButton: Colors.white,
      backgroundHintButton: color3,

      colorIcons: color2,
      colorSuccess: color4,
      colorFailure: color4,
      colorHeart: color4,
      colorHeartBroken: color2,

      textPuzzlePanel: color3,
      textPuzzleSymbols: Colors.white,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color3,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: Colors.white,
      textInputSymbols: Colors.white,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbols: color2,
      backgroundInputSymbolsFlipped: color4,
      textInputButton: color4,
      backgroundInputButton: color1,
    );
  }

  factory GameColorScheme.theme7() {

    var color1 = _fromHex("32012F");
    var color2 = _fromHex("524C42");
    var color3 = _fromHex("E2DFD0");
    var color4 = _fromHex("F97300");

    return GameColorScheme(
      backgroundTopPanel: color1,
      backgroundPuzzlePanel: color2,
      backgroundInputPanel: color3,

      textTopPanel: color3,
      textTopButton: Colors.white,
      backgroundTopButton: color2,
      textHintButton: color1,
      backgroundHintButton: color3,

      colorIcons: Colors.yellow,
      colorSuccess: color4,
      colorFailure: color4,
      colorHeart: color4,
      colorHeartBroken: color2,

      textPuzzlePanel: Colors.white,
      textPuzzleSymbols: color1,
      textPuzzleSymbolsFlipped: color1,
      backgroundPuzzleSymbols: color3,
      backgroundPuzzleSymbolsFlipped: color4,

      textInputPanel: color1,
      textInputSymbols: Colors.white,
      textInputSymbolsFlipped: color1,
      backgroundInputSymbols: color2,
      backgroundInputSymbolsFlipped: color4,
      textInputButton: color4,
      backgroundInputButton: color1,
    );
  }

  static Color _fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff$hex' : hex;
    return Color(int.parse(hex, radix: 16));
  }
}
