import 'package:flutter_test/flutter_test.dart';
import 'package:timekeep/domain/clock.dart';

void main() {
  group('SystemClock', () {
    test('returns the current local time', () {
      final before = DateTime.now();
      final now = const SystemClock().now();
      final after = DateTime.now();

      expect(now.isUtc, isFalse);
      expect(now.isBefore(before), isFalse);
      expect(now.isAfter(after), isFalse);
    });
  });

  group('FixedClock', () {
    final start = DateTime(2026, 9, 23, 9);

    test('returns the given time until changed', () {
      final clock = FixedClock(start);

      expect(clock.now(), start);
      expect(clock.now(), start);
    });

    test('advance moves time forward', () {
      final clock = FixedClock(start)
        ..advance(const Duration(hours: 1, seconds: 1));

      expect(clock.now(), DateTime(2026, 9, 23, 10, 0, 1));
    });

    test('set jumps to any time', () {
      final clock = FixedClock(start)..set(DateTime(2026, 9, 24, 0, 0, 1));

      expect(clock.now(), DateTime(2026, 9, 24, 0, 0, 1));
    });
  });
}
