import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/providers.dart';
import '../../widgets/confirm_dialog.dart';

/// [새 트립](S01)·[이 세트로 트립](S05) 공통 진입. 진행 중 트립은 하나뿐이라
/// 이미 있으면 "기존 트립을 완료 처리할까요?"를 먼저 묻는다.
Future<void> startNewTrip(
  BuildContext context,
  WidgetRef ref, {
  String? setId,
}) async {
  final dao = ref.read(tripDaoProvider);
  final active = await dao.findActiveTrip();
  if (active != null) {
    if (!context.mounted) return;
    final ok = await showConfirmDialog(
      context,
      title: '기존 트립을 완료 처리할까요?',
      message: '진행 중인 트립은 하나만 둘 수 있어요.\n‘${active.name}’ 트립을 완료하고 새 트립을 만듭니다.',
      confirmLabel: '완료하고 계속',
    );
    if (!ok) return;
    await dao.completeTrip(active.id);
  }
  if (!context.mounted) return;
  await context.push(
    setId == null ? Routes.tripNew : Routes.tripNewWith(setId),
  );
}
