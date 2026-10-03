import 'package:flutter/widgets.dart';

import '../../data/daos/item_dao.dart';
import '../../domain/models/item.dart';
import '../../widgets/confirm_dialog.dart';

/// 커스텀 아이템 삭제 확인 + 삭제. S07 스와이프와 S08 [삭제]가 같이 쓴다.
/// 삭제했으면 true.
Future<bool> confirmAndDeleteCustomItem(
  BuildContext context, {
  required ItemDao dao,
  required Item item,
  required int setCount,
}) async {
  // 결정(2026-10-03): 완료된 트립 기록에서도 함께 빠진다(FK cascade).
  final lines = [
    if (setCount > 0) '세트 $setCount곳에서 함께 제거됩니다.',
    '이 아이템이 담긴 트립(완료된 트립 포함)에서도 빠집니다.',
  ];
  final ok = await showConfirmDialog(
    context,
    title: '‘${item.name}’ 삭제',
    message: lines.join('\n'),
    confirmLabel: '삭제',
    destructive: true,
  );
  if (!ok) return false;
  await dao.deleteCustomItem(item.id);
  return true;
}
