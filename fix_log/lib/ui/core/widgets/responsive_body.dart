import 'package:flutter/material.dart';

/// Caps content width on tablet/desktop-sized viewports so lists and forms
/// don't stretch edge-to-edge, while leaving phone-sized layouts untouched.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 700});

  final Widget child;
  final double maxWidth;

  static const _tabletBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _tabletBreakpoint) return child;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
