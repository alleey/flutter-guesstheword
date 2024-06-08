import 'package:flutter/material.dart';

class StatefulColorContainer extends StatefulWidget {
  final Widget child;
  final WidgetStateProperty<Color?> color;

  const StatefulColorContainer({
    super.key,
    required this.child,
    required this.color,
  });

  @override
  _StatefulColorContainerState createState() => _StatefulColorContainerState();
}

class _StatefulColorContainerState extends State<StatefulColorContainer> {
  final Set<WidgetState> _states = {};

  void _updateState(WidgetState state, bool value) {
    setState(() {
      if (value) {
        _states.add(state);
      } else {
        _states.remove(state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Focus(
        onFocusChange: (focused) => _updateState(WidgetState.focused, focused),
        child: MouseRegion(
        onEnter: (_) => _updateState(WidgetState.hovered, true),
        onExit: (_) => _updateState(WidgetState.hovered, false),
        child: GestureDetector(
          onTapDown: (_) => _updateState(WidgetState.pressed, true),
          onTapUp: (_) => _updateState(WidgetState.pressed, false),
          onTapCancel: () => _updateState(WidgetState.pressed, false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: widget.color.resolve(_states),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
