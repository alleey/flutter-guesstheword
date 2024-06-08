import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/app_color_scheme.dart';
import '../common/layout_constants.dart';
import 'common/responsive_layout.dart';


typedef ColorSchemeSelectionCallback = void Function(String schmeName);

class ColorSchemePicker extends StatelessWidget {

  final String selectedTheme;
  final ColorSchemeSelectionCallback onSelect;
  final WrapAlignment alignment;
  final ValueNotifier<String> _changeNotifier;

  ColorSchemePicker({
    super.key,
    required this.selectedTheme,
    required this.onSelect,
    this.alignment = WrapAlignment.center,

  }) : _changeNotifier = ValueNotifier<String>(selectedTheme);

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final itemSize = layout.get<Size>(AppLayoutConstants.colorSchemePickerItemSizeKey);

    return ValueListenableBuilder(
      valueListenable: _changeNotifier,
      builder: (context, selectedTheme, child) =>  Wrap(
        alignment: alignment,
          runSpacing: 2,
          spacing: 2,
          children: AppColorSchemes.all.mapIndexed((index, e) {

            return Semantics(
              label: selectedTheme == e.key ? "Theme ${index + 1} is active!" : "Apply theme ${index + 1}.",
              button: true,
              child: InkWell(
                canRequestFocus: true,
                onFocusChange: (focus) {
                  if (focus) {
                    _changeNotifier.value = e.key;
                    onSelect(e.key);
                  }
                },
                onTap: () {
                  _changeNotifier.value = e.key;
                  onSelect(e.key);
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
              ),
            );
          }
        ).toList()
      ),
    );
  }
}
