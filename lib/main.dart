import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
//import 'device_frame.dart';
import 'blocs/settings_bloc.dart';
import 'home_page.dart';
import 'services/data_service.dart';
import 'services/puzzle_service.dart';

Future<void> main() async {

  await globalDataService.initialize();
  //await globalDataService.resetData();
  await PuzzleService(dataService: globalDataService).importAll();

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_)
  {
    //runApp(const DeviceFrameWrapper(child: MyApp()));
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Guess The Word',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'BraahOne',
          ),
          home: const HomePage(),
        )
    );
  }
}
