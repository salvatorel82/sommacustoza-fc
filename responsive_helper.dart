import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < 768;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 768 && 
      MediaQuery.of(context).size.width < 1024;
  
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1024;
  
  static double screenWidth(BuildContext context) => 
      MediaQuery.of(context).size.width;
  
  static double screenHeight(BuildContext context) => 
      MediaQuery.of(context).size.height;
  
  static EdgeInsets screenPadding(BuildContext context) =>
      MediaQuery.of(context).padding;
  
  static double bottomSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;
  
  static double topSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.top;
  
  // Responsive padding based on screen size
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }
  
  // Responsive grid columns
  static int responsiveColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }
  
  // Responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }
  
  // Check if device is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  
  // Get responsive height
  static double responsiveHeight(BuildContext context, double percentage) =>
      screenHeight(context) * percentage;
  
  // Get responsive width  
  static double responsiveWidth(BuildContext context, double percentage) =>
      screenWidth(context) * percentage;
  
  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;
  
  // Device pixel ratio
  static double devicePixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;
  
  // Text scale factor
  static double textScaleFactor(BuildContext context) =>
      MediaQuery.of(context).textScaleFactor;
}

class MobileOptimizations {
  // Optimize text scale for accessibility
  static double clampTextScaleFactor(double textScaleFactor) {
    return textScaleFactor.clamp(0.8, 1.3);
  }
  
  // Safe area wrapper
  static Widget withSafeArea(Widget child, {
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }
  
  // Scrollable wrapper with physics
  static Widget scrollableColumn({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
  
  // Dismissible keyboard on tap
  static Widget dismissKeyboardOnTap(Widget child) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
  
  // Material splash wrapper
  static Widget withMaterialSplash({
    required Widget child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: splashColor,
        child: child,
      ),
    );
  }
}

// Extension methods for easier responsive design
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
  EdgeInsets get screenPadding => ResponsiveHelper.screenPadding(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isKeyboardVisible => ResponsiveHelper.isKeyboardVisible(this);
  
  EdgeInsets get responsivePadding => ResponsiveHelper.responsivePadding(this);
  int get responsiveColumns => ResponsiveHelper.responsiveColumns(this);
  
  double responsiveFontSize(double baseSize) => 
      ResponsiveHelper.responsiveFontSize(this, baseSize);
  
  double responsiveHeight(double percentage) => 
      ResponsiveHelper.responsiveHeight(this, percentage);
  
  double responsiveWidth(double percentage) => 
      ResponsiveHelper.responsiveWidth(this, percentage);
}
