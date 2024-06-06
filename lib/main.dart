import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guess_the_word/services/app_data_service.dart';
import 'package:provider/provider.dart';

import 'blocs/game_bloc.dart';
//import 'device_frame.dart';
import 'blocs/settings_bloc.dart';
import 'common/constants.dart';
import 'common/layout_constants.dart';
import 'home_page.dart';
import 'localizations/app_localizations.dart';
import 'localizations/locale_provider.dart';
import 'services/data_service.dart';
import 'widgets/common/responsive_layout.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await DataService().initialize();
  //await globalDataService.resetData();

  final locale = AppDataService().getSetting(KnownSettingsNames.settingLocale, "en");
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(Locale(locale)),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _setPortraitOnlyMode() async
    => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameBloc>(create: (BuildContext context) => GameBloc()),
        BlocProvider<SettingsBloc>(create: (BuildContext context) => SettingsBloc()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {

          return ResponsiveLayoutProvider(

            constraints: constraints,
            breakpoints:  ResponsiveValue.from(small: 600, medium: 1200),
            provider: (layout) {

              if (!kIsWeb && layout.isSmall) {
                _setPortraitOnlyMode();
              }

              layout.provideAll(AppLayoutConstants.layout);
              layout.provideAll(DialogLayoutConstants.layout);
            },

            child: Consumer<LocaleProvider>(
              builder: (BuildContext context, LocaleProvider localeProvider, Widget? child) {

                log("app locale set to ${localeProvider.value}");

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: Constants.locales.map((locale) => Locale(locale, '')),
                  locale: localeProvider.value,
                  localeResolutionCallback: (locale, supportedLocales) {
                    return supportedLocales.firstWhere(
                      (l) => l.languageCode == locale?.languageCode,
                      orElse: () => supportedLocales.first
                    );
                  },
                  onGenerateTitle: (BuildContext context) => context.localizations.translate("app_title"),
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    fontFamily: 'Lilith',
                  ),
                  home: const HomePage(),
                );

              },
            ),
          );
        }
      ),
    );
  }
}
