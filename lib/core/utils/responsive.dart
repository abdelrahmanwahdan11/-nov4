import 'package:flutter/widgets.dart';

class ResponsiveBreakpoints {
  static const double compact = 480;
  static const double medium = 840;
  static const double large = 1200;
  static const double extraLarge = 1600;

  static int columnsForWidth(
    double width, {
    int min = 1,
    int max = 6,
  }) {
    int columns;
    if (width >= extraLarge) {
      columns = 6;
    } else if (width >= large) {
      columns = 5;
    } else if (width >= medium) {
      columns = 4;
    } else if (width >= compact) {
      columns = 3;
    } else {
      columns = min;
    }
    return columns.clamp(min, max);
  }

  static double foodCardAspectRatio(double width) {
    if (width >= extraLarge) {
      return 1.05;
    }
    if (width >= large) {
      return 0.95;
    }
    if (width >= medium) {
      return 0.85;
    }
    if (width >= compact) {
      return 0.78;
    }
    return 0.72;
  }

  static EdgeInsetsGeometry pagePadding(double width) {
    if (width >= extraLarge) {
      return const EdgeInsets.symmetric(horizontal: 64);
    }
    if (width >= large) {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
    if (width >= medium) {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  static double constrainedBodyWidth(double width) {
    if (width >= extraLarge) {
      return 1200;
    }
    if (width >= large) {
      return 1040;
    }
    if (width >= medium) {
      return 840;
    }
    return width;
  }
}
