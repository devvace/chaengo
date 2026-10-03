/// 날짜 표시. intl 없이 한국어 고정 형식만 쓴다(파일럿은 한국어 단일).
abstract final class TripFormat {
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  /// "10월 3일 금" — S01 앱바 오늘 날짜.
  static String today(DateTime d) =>
      '${d.month}월 ${d.day}일 ${_weekdays[d.weekday - 1]}';

  /// "9월 26일 – 27일", 달이 다르면 "9월 30일 – 10월 1일", 하루면 "9월 26일".
  static String range(DateTime start, DateTime end) {
    final head = '${start.month}월 ${start.day}일';
    if (_sameDay(start, end)) return head;
    if (start.year == end.year && start.month == end.month) {
      return '$head – ${end.day}일';
    }
    return '$head – ${end.month}월 ${end.day}일';
  }

  /// "10/4(토)" — S02 날짜 칸.
  static String short(DateTime d) =>
      '${d.month}/${d.day}(${_weekdays[d.weekday - 1]})';

  /// S01 "진행 중" 옆 문구. 출발 전 "출발까지 n일", 당일 "오늘 출발",
  /// 기간 중 "캠핑 중", 끝난 뒤에는 null(표시 안 함).
  static String? countdown(DateTime start, DateTime end, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (today.isBefore(s)) return '출발까지 ${s.difference(today).inDays}일';
    if (today == s) return '오늘 출발';
    if (!today.isAfter(e)) return '캠핑 중';
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// S02 기본 날짜: 이번 주 토·일. 일요일이면 어제(토)부터 오늘까지.
  static ({DateTime start, DateTime end}) thisWeekend(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.weekday == DateTime.sunday
        ? today.subtract(const Duration(days: 1))
        : today.add(Duration(days: DateTime.saturday - today.weekday));
    return (start: start, end: start.add(const Duration(days: 1)));
  }
}
