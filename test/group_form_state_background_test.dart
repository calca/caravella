import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';

void main() {
  group('GroupFormState background behavior', () {
    test('setColor(null) should clear color', () {
      final state = GroupFormState();
      
      // Set a color
      const testColor = 0xFF42A5F5;
      state.setColor(testColor);
      expect(state.color, equals(testColor));
      
      // Clear the color
      state.setColor(null);
      expect(state.color, isNull);
    });

    test('setImage(null) should clear imagePath but NOT color', () {
      final state = GroupFormState();
      
      // Set both image and color
      state.setImage('/path/to/image.jpg');
      state.setColor(0xFF42A5F5);
      
      // Note: setColor should have cleared imagePath
      expect(state.imagePath, isNull);
      expect(state.color, equals(0xFF42A5F5));
      
      // Now set image to null - this should NOT clear color
      state.setImage(null);
      expect(state.imagePath, isNull);
      expect(state.color, equals(0xFF42A5F5), reason: 'setImage(null) should not clear color');
    });

    test('removeImage simulation - both calls should clear everything', () {
      final state = GroupFormState();
      
      // Set only color (no image)
      const testColor = 0xFF42A5F5;
      state.setColor(testColor);
      expect(state.color, equals(testColor));
      expect(state.imagePath, isNull);
      
      // Simulate removeImage() - it calls both setImage(null) and setColor(null)
      state.setImage(null);  // Should not affect color since it's already null
      state.setColor(null);  // Should clear color
      
      expect(state.imagePath, isNull);
      expect(state.color, isNull);
    });

    test('mutual exclusion: setting image clears color', () {
      final state = GroupFormState();
      
      // Set color first
      state.setColor(0xFF42A5F5);
      expect(state.color, equals(0xFF42A5F5));
      expect(state.imagePath, isNull);
      
      // Set image - should clear color
      state.setImage('/path/to/image.jpg');
      expect(state.imagePath, equals('/path/to/image.jpg'));
      expect(state.color, isNull);
    });

    test('mutual exclusion: setting color clears image', () {
      final state = GroupFormState();
      
      // Set image first
      state.setImage('/path/to/image.jpg');
      expect(state.imagePath, equals('/path/to/image.jpg'));
      expect(state.color, isNull);
      
      // Set color - should clear image
      state.setColor(0xFF42A5F5);
      expect(state.color, equals(0xFF42A5F5));
      expect(state.imagePath, isNull);
    });
  });
}