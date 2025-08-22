import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/widgets/material3_segmented_button.dart';

void main() {
  group('Material3SegmentedButton', () {
    testWidgets('should render with single selection', (WidgetTester tester) async {
      const segments = {
        ButtonSegment<String>(value: 'option1', label: Text('Option 1')),
        ButtonSegment<String>(value: 'option2', label: Text('Option 2')),
      };
      
      Set<String> selected = {'option1'};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3SegmentedButton<String>(
              segments: segments,
              selected: selected,
              onSelectionChanged: (newSelection) {
                selected = newSelection;
              },
            ),
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('should support multi-selection', (WidgetTester tester) async {
      const segments = {
        ButtonSegment<String>(value: 'option1', label: Text('Option 1')),
        ButtonSegment<String>(value: 'option2', label: Text('Option 2')),
        ButtonSegment<String>(value: 'option3', label: Text('Option 3')),
      };
      
      Set<String> selected = {'option1', 'option2'};
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3SegmentedButton<String>(
              segments: segments,
              selected: selected,
              multiSelectionEnabled: true,
              onSelectionChanged: (newSelection) {
                selected = newSelection;
              },
            ),
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
      
      final segmentedButton = tester.widget<SegmentedButton<String>>(
        find.byType(SegmentedButton<String>),
      );
      expect(segmentedButton.multiSelectionEnabled, isTrue);
    });

    testWidgets('should expand to full width when specified', (WidgetTester tester) async {
      const segments = {
        ButtonSegment<String>(value: 'option1', label: Text('Option 1')),
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: Material3SegmentedButton<String>(
                segments: segments,
                selected: {'option1'},
                expandedWidth: true,
              ),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(SegmentedButton<String>),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, equals(double.infinity));
    });

    group('Helper methods', () {
      test('createTextSegments should create segments from map', () {
        final options = {
          'key1': 'Label 1',
          'key2': 'Label 2',
        };
        
        final segments = Material3SegmentHelpers.createTextSegments(options);
        expect(segments.length, equals(2));
        
        final segmentValues = segments.map((s) => s.value).toSet();
        expect(segmentValues, equals({'key1', 'key2'}));
      });

      test('createIconSegments should create icon segments from map', () {
        final options = {
          'key1': Icons.home,
          'key2': Icons.settings,
        };
        
        final segments = Material3SegmentHelpers.createIconSegments(options);
        expect(segments.length, equals(2));
        
        final segmentValues = segments.map((s) => s.value).toSet();
        expect(segmentValues, equals({'key1', 'key2'}));
      });

      test('createSegment should create single segment', () {
        final segment = Material3SegmentHelpers.createSegment<String>(
          value: 'test',
          label: 'Test Label',
          icon: Icons.star,
          tooltip: 'Test tooltip',
        );
        
        expect(segment.value, equals('test'));
        expect(segment.tooltip, equals('Test tooltip'));
        expect(segment.enabled, isTrue);
      });
    });
  });
}