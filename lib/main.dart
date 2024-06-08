import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/game_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'common/constants.dart';
import 'common/layout_constants.dart';
import 'home_page.dart';
import 'localizations/app_localizations.dart';
import 'models/app_settings.dart';
import 'services/data_service.dart';
import 'widgets/common/responsive_layout.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await DataService().initialize();
  //await DataService().resetData();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> _setPortraitOnlyMode() async
    => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  var _settings = AppSettings();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<GameBloc>(create: (BuildContext context) => GameBloc()),
      BlocProvider<SettingsBloc>(create: (BuildContext context)
        => SettingsBloc()..add(ReadSettingsBlocEvent())
      ),
    ],
    child: LayoutBuilder(
      builder: (context, constraints) => ResponsiveLayoutProvider(

        constraints: constraints,
        breakpoints:  ResponsiveValue.from(small: 600, medium: 1200),
        provider: (layout) {

          if (!kIsWeb && layout.isSmall) {
            _setPortraitOnlyMode();
          }

          layout.provideAll(AppLayoutConstants.layout);
          layout.provideAll(DialogLayoutConstants.layout);
        },

        child: BlocListener<SettingsBloc, SettingsBlocState>(
          listener: (BuildContext context, state) {
            log("Main> listener SettingsBloc: $state");
            if(state is SettingsReadBlocState) {
              log("Main> SettingsReadBlocState: ${state.settings}");
              setState(() {
                _settings = state.settings;
              });
            }
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: Constants.locales.map((locale) => Locale(locale, '')),
            locale: Locale(_settings.locale),
            localeResolutionCallback: (locale, supportedLocales) {
              return supportedLocales.firstWhere(
                (l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first
              );
            },
            onGenerateTitle: (BuildContext context) => context.localizations.translate("app_title"),
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: _settings.font,
            ),
            home: const HomePage(),
          )
        ),
      ),
    ),
  );
}
