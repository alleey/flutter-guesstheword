import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/game_color_scheme.dart';


typedef ColorSchemeSelectionCallback = void Function(String schmeName);

class ColorSchemePicker extends StatefulWidget {

  final String selectedTheme;
  final ColorSchemeSelectionCallback onSelect;

  const ColorSchemePicker({
    super.key,
    required this.selectedTheme,
    required this.onSelect
  });

  @override
  State<ColorSchemePicker> createState() => _ColorSchemePickerState();
}

class _ColorSchemePickerState extends State<ColorSchemePicker> {

  late String selectedTheme;

  @override
  void initState() {
    selectedTheme = widget.selectedTheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
        runSpacing: 3,
        spacing: 3,
        children: GameColorSchemes.all.mapIndexed((index, e) =>
          InkWell(
            onTap: () {
              setState(() {
                selectedTheme = e.key;
                widget.onSelect(selectedTheme);
              });
            },
            child: Container(
              height: 80,
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (e.key == selectedTheme) ? Colors.black : Colors.transparent,
                  width: 3
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    Expanded(child: Container(color: e.value.backgroundTopPanel, child: const SizedBox(height: 100, width: 100,),)),
                    Expanded(child: Container(color: e.value.backgroundPuzzlePanel, child: const SizedBox(height: 100, width: 100,),)),
                    Expanded(child: Container(color: e.value.backgroundInputPanel, child: const SizedBox(height: 100, width: 100,),)),
                  ]
                ),
              ),
            ),
          )
      ).toList()
    );
  }
}
