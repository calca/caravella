import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'ExpenseGroupDetailPage uses the home gradient when the group has a color',
    () {
      const groupColor = 0xFFE57373;
      final group = ExpenseGroup(
        id: 'detail-gradient-group',
        title: 'Color Group',
        expenses: const [],
        participants: [ExpenseParticipant(id: '1', name: 'Alice')],
        categories: [ExpenseCategory(id: '1', name: 'Food')],
        currency: 'EUR',
        color: groupColor,
      );

      final colorScheme = ThemeData.light().colorScheme;
      final bg = GroupBackgroundUtils.resolve(
        group,
        colorScheme,
        baseColor: colorScheme.surfaceContainer,
      );

      expect(bg.gradient, isNotNull);

      final gradient = bg.gradient!;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.stops, const [0.0, 0.65]);

      final expectedTop = const Color(groupColor).withValues(alpha: 0.95);
      final expectedBottom = const Color(groupColor).withValues(alpha: 0.1);
      expect(gradient.colors, [expectedTop, expectedBottom]);
    },
  );
}
