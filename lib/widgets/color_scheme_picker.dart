import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/game_color_scheme.dart';
import '../common/layout_constants.dart';
import 'common/responsive_layout.dart';


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

    final layout = ResponsiveLayoutProvider.layout(context);
    final itemSize = layout.get<Size>(AppLayoutConstants.themePickerItemSizeKey);

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
              height: itemSize.height,
              width: itemSize.width,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (e.key == selectedTheme) ? e.value.textPuzzlePanel : Colors.transparent,
                  width: 3
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: e.value.backgroundTopPanel,
                        child: SizedBox(height: itemSize.height, width: itemSize.width,),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: e.value.backgroundPuzzlePanel,
                        child: SizedBox(height: itemSize.height, width: itemSize.width,),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: e.value.backgroundInputPanel,
                        child: SizedBox(height: itemSize.height, width: itemSize.width,),
                      ),
                    ),
                  ]
                ),
              ),
            ),
          )
      ).toList()
    );
  }
}
