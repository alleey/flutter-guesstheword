
class Constants
{
  static const int appDataVersion = 1;
  static const int maxErrors = 6;
  static const int maxScoreHistory = 10;
  static const int scoreBumpForHintBonus = 100;

  static const String symbolSet = "abcdefghijklmnopqrstuvwxyz&";

  static const bool enableInitialReveal = true;

  static const int difficultyEasyLen = 8;
  static const int difficultyMediumLen = 12;

  static const int revealEasy = 1;
  static const int revealMedium = 2;
  static const int revealHard = 3;

  static const List<String> locales = ['en'];

  static const puzzleSets = [
    "animals", "birds", "cars", "cartoons", "capitals",
    "countries", "desserts",
    "elements", "emotions", "flowers", "fruits", "martialarts", "moons",
    "olympics", "scientists", "sea-creatures", "superheroes",
    "vegetables",
  ];
}
