import 'package:flutter/material.dart';

/// Scrollable, centered content column shared by every screen.
class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.builder});

  final List<Widget> Function(BuildContext context, double width) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = constraints.maxWidth < 600 ? 16.0 : 32.0;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: builder(context, constraints.maxWidth),
              ),
            ),
          ),
        );
      },
    );
  }
}
