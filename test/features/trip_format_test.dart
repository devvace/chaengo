import 'package:chaengo/features/trips/trip_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 10, 10);
  final end = DateTime(2026, 10, 11);

  test('출발 전·당일·기간 중·종료 후', () {
    expect(
      TripFormat.countdown(start, end, DateTime(2026, 10, 2, 23)),
      '출발까지 8일',
    );
    expect(
      TripFormat.countdown(start, end, DateTime(2026, 10, 9, 23, 59)),
      '출발까지 1일',
    );
    expect(
      TripFormat.countdown(start, end, DateTime(2026, 10, 10, 8)),
      '오늘 출발',
    );
    expect(
      TripFormat.countdown(start, end, DateTime(2026, 10, 11, 20)),
      '캠핑 중',
    );
    expect(TripFormat.countdown(start, end, DateTime(2026, 10, 12)), isNull);
  });

  test('이번 주 토·일: 평일이면 다가오는 토요일, 일요일이면 어제부터', () {
    final fri = TripFormat.thisWeekend(DateTime(2026, 10, 2));
    expect(fri.start, DateTime(2026, 10, 3));
    expect(fri.end, DateTime(2026, 10, 4));
    final sun = TripFormat.thisWeekend(DateTime(2026, 10, 4, 15));
    expect(sun.start, DateTime(2026, 10, 3));
  });
}
