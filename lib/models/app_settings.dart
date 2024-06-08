
class AppSettings {
  final String theme;
  final String locale;
  final String font;
  final bool playSounds;

  AppSettings({
    this.theme = "default",
    this.locale = "en",
    this.font = 'Lilith',
    this.playSounds = true,
  });

  AppSettings copyWith({
      String? theme,
      String? locale,
      String? font,
      bool? playSounds,
    })
  {
     return AppSettings(
      theme: theme ?? this.theme,
      locale: theme ?? this.locale,
      font: font ?? this.font,
      playSounds: playSounds ?? this.playSounds,
     );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: json['theme'] as String,
      locale: json['locale'] as String,
      font: json['font'] as String,
      playSounds: json['playSounds'] as bool,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'locale': locale,
      'font': font,
      'playSounds': playSounds,
    };
  }

  @override
  String toString() {
    return 'AppSettings(playSounds: $playSounds, locale: $locale, font: $font, theme: $theme)';
  }
}