/// Which section a horizontal swipe leads to (the group page's Expenses /
/// Balances / Statistics, the Groups page's Active / Archived), or null to
/// stay: a swipe towards the start (left in LTR) opens the next section, one
/// towards the end the previous one. A swipe counts when it travelled
/// [minDistance] or was flung faster than [minVelocity].
int? sectionAfterSwipe({
  required int current,
  required int count,
  required double distance,
  required double velocity,
  bool rtl = false,
  double minDistance = 80,
  double minVelocity = 400,
}) {
  final forward = rtl ? 1.0 : -1.0;
  final dir = velocity.abs() >= minVelocity
      ? velocity.sign
      : distance.abs() >= minDistance
      ? distance.sign
      : 0.0;
  if (dir == 0) return null;
  final next = current + (dir == forward ? 1 : -1);
  return next < 0 || next >= count ? null : next;
}
