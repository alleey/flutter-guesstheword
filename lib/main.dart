import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
//import 'device_frame.dart';
import 'blocs/settings_bloc.dart';
import 'common/layout_constants.dart';
import 'home_page.dart';
import 'services/data_service.dart';
import 'services/puzzle_service.dart';
import 'widgets/common/responsive_layout.dart';

Future<void> main() async {

  await globalDataService.initialize();
  //await globalDataService.resetData();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _setPortraitOnlyMode() async
    => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameBloc>(
          create: (BuildContext context) => GameBloc(),
        ),
        BlocProvider<SettingsBloc>(
          create: (BuildContext context) => SettingsBloc(),
        ),
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

            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Guess The Word',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                fontFamily: 'Lilita',
              ),
              home: const HomePage(),
            ),
          );

        }
      ),
    );
  }
}
