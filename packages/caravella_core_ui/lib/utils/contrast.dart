import 'dart:math' as math;
import 'package:flutter/material.dart';

/// WCAG 2.x relative luminance / contrast ratio helpers, for verifying
/// (in code or tests) that a color pairing meets accessibility contrast
/// requirements instead of eyeballing it.
class ContrastUtils {
  ContrastUtils._();

  /// WCAG AA minimum contrast ratio for normal-sized text (SC 1.4.3).
  static const double aaNormalText = 4.5;

  /// WCAG AA minimum contrast ratio for large-scale text (18pt+, or 14pt+
  /// bold) and for non-text UI components like icons/borders (SC 1.4.3,
  /// 1.4.11).
  static const double aaLargeTextOrUi = 3.0;

  /// Relative luminance per the WCAG 2.x definition:
  /// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  static double relativeLuminance(Color color) {
    double channel(double c) {
      return c <= 0.03928
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = channel(color.r);
    final g = channel(color.g);
    final b = channel(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Contrast ratio between two colors, from 1 (identical) to 21 (black on
  /// white).
  ///
  /// If [foreground] is translucent (e.g. `Colors.white54`), it's first
  /// alpha-composited over [background] to get the actually-rendered color
  /// — comparing raw un-blended channels would ignore alpha entirely and
  /// always report the fully-opaque color's ratio, regardless of how
  /// transparent the foreground really is.
  static double contrastRatio(Color foreground, Color background) {
    final effectiveForeground = Color.alphaBlend(foreground, background);
    final la = relativeLuminance(effectiveForeground);
    final lb = relativeLuminance(background);
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Whether [foreground] on [background] meets [minRatio] (defaults to the
  /// WCAG AA normal-text threshold).
  static bool meetsContrast(
    Color foreground,
    Color background, {
    double minRatio = aaNormalText,
  }) {
    return contrastRatio(foreground, background) >= minRatio;
  }
}
