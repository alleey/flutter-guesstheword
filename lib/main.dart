import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/game_bloc.dart';
import 'home_page.dart';
import 'services/data_service.dart';
import 'services/puzzle_service.dart';

// The only global we have to tolerate
final globalDataService = DataService();

Future<void> main() async {
  await globalDataService.initialize();
  //await globalDataService.resetData();
  await PuzzleService(dataService: globalDataService).importAll();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<GameBloc>(
            create: (BuildContext context) => GameBloc(),
          )
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
