import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/backup/backup_codec.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../widgets/confirm_dialog.dart';
import 'settings_state.dart';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// 내보내기: 임시 파일 → OS 공유 시트. iPad는 [origin]이 없으면 크래시하므로
/// 누른 버튼의 위치를 항상 넘긴다(Android에서는 무시된다).
Future<void> exportBackup(
  BuildContext context,
  WidgetRef ref, {
  required Rect origin,
}) async {
  final json = await BackupCodec(ref.read(appDatabaseProvider)).exportJson();
  final now = DateTime.now();
  final stamp =
      '${now.year}${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}';
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/chaengo-$stamp.json');
  await file.writeAsString(json);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: '챙고 백업 $stamp',
      sharePositionOrigin: origin,
    ),
  );
}

/// 가져오기: 파일 선택 → 검증 → 확인 2단계 → 덮어쓰기.
Future<void> importBackup(BuildContext context, WidgetRef ref) async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (picked == null || !context.mounted) return;

  final codec = BackupCodec(ref.read(appDatabaseProvider));
  final BackupData data;
  try {
    data = codec.parse(utf8.decode(await picked.readAsBytes()));
  } on BackupVersionException catch (e) {
    if (context.mounted) {
      await showConfirmDialog(
        context,
        title: '가져올 수 없는 백업이에요',
        message:
            '다른 버전의 앱에서 만든 파일이에요.\n'
            '(파일 v${e.fileVersion}, 앱 v$kSchemaVersion)',
        confirmLabel: '확인',
      );
    }
    return;
  } on Object {
    if (context.mounted) {
      await showConfirmDialog(
        context,
        title: '백업 파일을 읽지 못했어요',
        message: '챙고에서 내보낸 JSON 파일인지 확인해 주세요.',
        confirmLabel: '확인',
      );
    }
    return;
  }
  if (!context.mounted) return;

  final at = data.exportedAt;
  final when = at == null ? '' : '\n${at.year}.${at.month}.${at.day} 내보냄';
  final first = await showConfirmDialog(
    context,
    title: '이 백업을 가져올까요?',
    message:
        '아이템 ${data.itemCount}개 · 세트 ${data.setCount}개 · '
        '트립 ${data.tripCount}개$when',
    confirmLabel: '다음',
  );
  if (!first || !context.mounted) return;
  final second = await showConfirmDialog(
    context,
    title: '현재 데이터를 덮어쓸까요?',
    message: '지금 기기에 있는 아이템·세트·트립이 모두 백업 내용으로 바뀌어요. 되돌릴 수 없어요.',
    confirmLabel: '덮어쓰기',
    destructive: true,
  );
  if (!second) return;

  await codec.restore(data);
  if (context.mounted) _toast(context, '백업을 가져왔어요');
}

/// 전체 초기화: "초기화"를 직접 입력해야 진행된다.
Future<void> resetAll(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => const _ResetDialog(),
  );
  if (ok != true) return;
  await ref.read(seedLoaderProvider).resetToSeed();
  if (context.mounted) _toast(context, '초기화했어요');
}

/// 피드백 메일. url_launcher는 mailto에만 쓴다(네트워크 URL 금지).
Future<void> sendFeedback(BuildContext context, AppInfo? info) async {
  final body = [
    '',
    '',
    '---',
    if (info != null) ...[
      '앱 버전: ${info.version} (${info.build})',
      if (info.device.isNotEmpty) '기기: ${info.device}',
      'OS: ${info.os}',
    ],
  ].join('\n');
  final uri = Uri.parse(
    'mailto:$kFeedbackEmail'
    '?subject=${Uri.encodeComponent('[챙고] 피드백')}'
    '&body=${Uri.encodeComponent(body)}',
  );
  var opened = false;
  try {
    opened = await launchUrl(uri);
  } on Object {
    opened = false;
  }
  if (!opened && context.mounted) {
    _toast(context, '메일 앱을 열 수 없어요. $kFeedbackEmail 로 보내 주세요.');
  }
}

class _ResetDialog extends StatefulWidget {
  const _ResetDialog();

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  static const _keyword = '초기화';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('전체 초기화'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '커스텀 아이템·세트·트립이 모두 지워지고 기본 아이템과 기본 세트만 남아요. '
            '계속하려면 ‘$_keyword’를 입력하세요.',
            style: AppText.body,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: _keyword),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.inkSub),
          child: const Text('취소'),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => TextButton(
            onPressed: _controller.text.trim() == _keyword
                ? () => Navigator.of(context).pop(true)
                : null,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('초기화'),
          ),
        ),
      ],
    );
  }
}
