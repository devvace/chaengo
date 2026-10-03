import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 여러 AsyncValue를 하나로 합친다. 하나라도 에러면 에러, 하나라도 값이
/// 아직 없으면 로딩, 모두 값이 있으면 [combine] 결과.
///
/// 화면 UiState를 Future provider로 만들면 의존 스트림이 바뀔 때마다
/// 로딩 상태를 거쳐 한 프레임 깜빡이므로, 동기 provider에서 이걸 쓴다.
AsyncValue<T> combineAsync<T>(
  List<AsyncValue<Object?>> sources,
  T Function() combine,
) {
  for (final source in sources) {
    if (source case AsyncError(:final error, :final stackTrace)) {
      return AsyncError(error, stackTrace);
    }
  }
  if (sources.any((s) => !s.hasValue)) return const AsyncLoading();
  return AsyncData(combine());
}
