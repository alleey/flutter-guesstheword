import 'package:flutter/material.dart';

import '../common/app_color_scheme.dart';
import '../common/layout_constants.dart';
import 'common/responsive_layout.dart';

class LoadingIndicator extends StatelessWidget {

  const LoadingIndicator({
    super.key,
    required this.colorScheme,
    this.message = "loading . . ."
  });

  final String message;
  final AppColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final titleFontSize = layout.get<double>(AppLayoutConstants.titleFontSizeKey);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: colorScheme.textPuzzlePanel,
              fontSize: titleFontSize,
            ),
          ),
          const SizedBox(height: 16), // Spacer
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: LinearProgressIndicator(
              color: colorScheme.textPuzzlePanel,
              backgroundColor: colorScheme.backgroundPuzzlePanel,
            ),
          )
        ],
      ),
    );
  }
}