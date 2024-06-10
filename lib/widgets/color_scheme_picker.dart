import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/app_color_scheme.dart';
import '../common/layout_constants.dart';
import 'common/focus_highlight.dart';
import 'common/responsive_layout.dart';


typedef ColorSchemeSelectionCallback = void Function(String schmeName);

class ColorSchemePicker extends StatefulWidget {

  final String selectedTheme;
  final ColorSchemeSelectionCallback onSelect;
  final WrapAlignment alignment;

  const ColorSchemePicker({
    super.key,
    required this.selectedTheme,
    required this.onSelect,
    this.alignment = WrapAlignment.center,

  });

  @override
  State<ColorSchemePicker> createState() => _ColorSchemePickerState();
}

class _ColorSchemePickerState extends State<ColorSchemePicker> {

  late ValueNotifier<(int, String)> _changeNotifier;
  final List<FocusNode> _focusNodes = List.generate(AppColorSchemes.all.length, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    focusSelectedTheme();
    // if (selectedThemeIndex >= 0) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       _focusNodes[selectedThemeIndex].requestFocus();
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    _changeNotifier.dispose();
    super.dispose();
  }

  void focusSelectedTheme() {
    int selectedThemeIndex = AppColorSchemes.all
      .mapIndexed((i,e) => (i, e.key))
      .where((e) => e.$2 == widget.selectedTheme)
      .map((e) => e.$1)
      .firstOrNull ?? -1;
    _changeNotifier = ValueNotifier<(int, String)>((selectedThemeIndex, widget.selectedTheme));
  }

  @override
  Widget build(BuildContext context) {

    final layout = context.layout;
    final itemSize = layout.get<Size>(AppLayoutConstants.colorSchemePickerItemSizeKey);

    return Focus(
      canRequestFocus: false,
      onFocusChange:(value) {
        if (value) {
          focusSelectedTheme();
        }
      },
      child: ValueListenableBuilder(
        valueListenable: _changeNotifier,
        builder: (context, value, child) {

          final (selectedIndex, _) = value;

          return Wrap(
            alignment: widget.alignment,
              runSpacing: 2,
              spacing: 2,
              children: AppColorSchemes.all.mapIndexed((index, e) {

                return Semantics(
                  label: selectedIndex == index ? "Theme ${index + 1} is active!" : "Apply theme ${index + 1}.",
                  button: true,
                  child: FocusHighlight(
                    focusColor: e.value.textPuzzlePanel,
                    child: InkWell(
                      focusNode: _focusNodes[index],
                      canRequestFocus: true,
                      onFocusChange: (focus) {
                        if (focus) {
                          _changeNotifier.value = (index, e.key);
                          widget.onSelect(e.key);
                        }
                      },
                      onTap: () {
                        _changeNotifier.value = (index, e.key);
                        widget.onSelect(e.key);
                      },
                      child: SizedBox(
                        height: itemSize.height,
                        width: itemSize.width,
                        // decoration: BoxDecoration(
                        //   border: Border.all(
                        //     color: (e.key == selectedTheme) ? e.value.textPuzzlePanel : Colors.transparent,
                        //     width: 3
                        //   )
                        // ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
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
                  ),
                );
              }
            ).toList()
          );
        },
      ),
    );
  }
}
