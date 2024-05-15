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
        runSpacing: 15,
        spacing: 15,
        children: GameColorSchemes.all.mapIndexed((index, e) =>
          InkWell(
            onTap: () {
              setState(() {
                selectedTheme = e.key;
                if (widget.selectedTheme != selectedTheme) {
                  widget.onSelect(selectedTheme);
                }
              });
            },
            child: Container(
              height: 90,
              width: 75,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (e.key == selectedTheme) ? const Color.fromARGB(255, 8, 254, 16) : Colors.transparent,
                  width: 8
                )
              ),
              child: Column(
                children: [
                  Expanded(child: Container(color: e.value.backgroundTopPanel, child: const SizedBox(height: 100, width: 100,),)),
                  Expanded(child: Container(color: e.value.backgroundPuzzlePanel, child: const SizedBox(height: 100, width: 100,),)),
                  Expanded(child: Container(color: e.value.backgroundInputPanel, child: const SizedBox(height: 100, width: 100,),)),
                ]
              ),
            ),
          )
      ).toList()
    );
  }
}
