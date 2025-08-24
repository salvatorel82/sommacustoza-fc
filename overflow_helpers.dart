import 'package:flutter/material.dart';

/// Widget helper per evitare overflow nei dialog
class ScrollableDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;
  final double? maxHeight;
  final double? maxWidth;

  const ScrollableDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
    this.maxHeight,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    Widget dialogContent = content;
    
    if (scrollable) {
      dialogContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? screenHeight * 0.7,
          maxWidth: maxWidth ?? screenWidth * 0.9,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        ),
      );
    }

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: dialogContent,
      ),
      actions: actions,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
    );
  }
}

/// Widget helper per form lunghi
class ScrollableFormScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showAppBar;
  final Color? backgroundColor;

  const ScrollableFormScreen({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showAppBar = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child,
              if (actions != null) ...[
                const SizedBox(height: 32),
                ...actions!,
              ],
              const SizedBox(height: 32), // Extra space for keyboard
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin per gestire overflow negli screen
mixin OverflowHandlingMixin {
  
  /// Wrapper per evitare overflow in Column
  Widget buildSafeColumn({
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool scrollable = true,
    EdgeInsetsGeometry? padding,
  }) {
    final column = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );

    if (scrollable) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: column,
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: column,
    );
  }

  /// Wrapper per evitare overflow in Row
  Widget buildSafeRow({
    required List<Widget> children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    bool scrollable = false,
  }) {
    final row = Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: row,
      );
    }

    return row;
  }

  /// Safe container con dimensioni responsive
  Widget buildResponsiveContainer({
    required Widget child,
    double? height,
    double? width,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
  }) {
    return Builder(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        
        return Container(
          height: height,
          width: width,
          constraints: BoxConstraints(
            maxWidth: screenSize.width * 0.95,
            maxHeight: screenSize.height * 0.8,
          ),
          padding: padding,
          margin: margin,
          decoration: decoration,
          child: child,
        );
      },
    );
  }
}
