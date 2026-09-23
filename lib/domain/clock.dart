/// Source of the current time.
///
/// Always inject a [Clock] instead of calling `DateTime.now()` so that
/// business rules can be tested at exact boundaries.
abstract interface class Clock {
  /// Current local time.
  DateTime now();
}

/// [Clock] backed by the device time.
class SystemClock implements Clock {
  /// Creates a clock reading the device time.
  const new();

  @override
  DateTime now() => DateTime.now();
}

/// [Clock] frozen at a given time, moved only on demand. Meant for tests.
class FixedClock implements Clock {
  /// Creates a clock frozen at [now].
  new(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Jumps to [now].
  // A setter would clash with the `now()` method.
  // ignore: use_setters_to_change_properties
  void set(DateTime now) => _now = now;

  /// Moves time forward by [duration].
  void advance(Duration duration) => _now = _now.add(duration);
}
