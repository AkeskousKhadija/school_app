import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double mobile = 576;
  static const double tablet = 768;
  static const double desktop = 992;
  static const double largeDesktop = 1200;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

class AppTheme {
  static const Color primaryBlue = Color(0xFF3A98C7);
  static const Color darkBlue = Color(0xFF1A2E78);
  static const Color lightBlue = Color(0xFF03A9F4);
  static const Color cardBg = Color(0xFFE3F2FD);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: const Color(0xFFF2EFEA),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenSize) mobileBuilder;
  final Widget Function(BuildContext, ScreenSize)? tabletBuilder;
  final Widget Function(BuildContext, ScreenSize)? desktopBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= AppBreakpoints.desktop && desktopBuilder != null) {
      return desktopBuilder!(context, ScreenSize.desktop);
    } else if (screenWidth >= AppBreakpoints.tablet && tabletBuilder != null) {
      return tabletBuilder!(context, ScreenSize.tablet);
    } else {
      return mobileBuilder(context, ScreenSize.mobile);
    }
  }
}

enum ScreenSize { mobile, tablet, desktop }

extension ScreenSizeExtension on ScreenSize {
  bool get isMobile => this == ScreenSize.mobile;
  bool get isTablet => this == ScreenSize.tablet;
  bool get isDesktop => this == ScreenSize.desktop;
}