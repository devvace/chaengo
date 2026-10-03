import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import 'settings_actions.dart';
import 'settings_state.dart';

/// 아이콘 라이선스 표기(필수). LICENSE-game-icons.txt + INDEX-addendum.md 작성자 전부.
const kIconAttribution =
    'Icons by Delapouite, Lorc, sbed, Caro Asercion — game-icons.net (CC BY 3.0). '
    '일부 아이콘은 챙고 자체 제작.';

/// S09 설정 — 하단 탭 4.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(settingsUiStateProvider);
    final info = ref.watch(appInfoProvider).value;
    final dao = ref.read(settingsDaoProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ui.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Center(child: Text('불러오지 못했어요\n$e')),
          data: (state) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  16,
                  AppSizes.screenPadding,
                  4,
                ),
                child: Text('설정', style: AppText.screenTitle),
              ),
              const _Section('데이터'),
              Builder(
                // 공유 시트 기준 위치(iPad)를 얻으려고 이 행의 context를 쓴다.
                builder: (rowContext) => _Row(
                  title: '백업 파일 내보내기',
                  subtitle: '아이템·세트·트립 전체, JSON',
                  trailing: const Icon(
                    Icons.ios_share,
                    color: AppColors.inkSub,
                  ),
                  onTap: () => exportBackup(
                    rowContext,
                    ref,
                    origin: _originOf(rowContext),
                  ),
                ),
              ),
              _Row(
                title: '백업 파일 가져오기',
                subtitle: '현재 데이터를 덮어써요',
                trailing: const Icon(
                  Icons.file_open_outlined,
                  color: AppColors.inkSub,
                ),
                onTap: () => importBackup(context, ref),
              ),
              _Row(
                title: '전체 초기화',
                subtitle: '기본 아이템·기본 세트만 남겨요',
                titleColor: AppColors.danger,
                onTap: () => resetAll(context, ref),
              ),
              const _Section('아이템'),
              _Row(
                title: '숨김 아이템 보기',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      withMonoDigits('${state.hiddenCount}개', AppText.caption),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.inkMute),
                  ],
                ),
                onTap: () => context.push(Routes.hiddenItems),
              ),
              const _Section('체크 화면'),
              _SwitchRow(
                title: '체크 중 화면 켜짐 유지',
                value: state.settings.keepScreenOn,
                onChanged: (v) =>
                    dao.saveSettings(state.settings.copyWith(keepScreenOn: v)),
              ),
              _SwitchRow(
                title: '탭 시 진동',
                value: state.settings.haptics,
                onChanged: (v) =>
                    dao.saveSettings(state.settings.copyWith(haptics: v)),
              ),
              const _Section('정보'),
              _Row(
                title: '버전',
                trailing: Text.rich(
                  withMonoDigits(
                    info == null ? '' : '${info.version} (${info.build})',
                    AppText.caption,
                  ),
                ),
              ),
              _Row(
                title: '기본 아이템 DB',
                trailing: Text.rich(
                  withMonoDigits(
                    'v$kSchemaVersion · ${state.builtInCount}개',
                    AppText.caption,
                  ),
                ),
              ),
              _Row(
                title: '피드백 보내기',
                subtitle: '메일 앱이 열려요. 버전·기기 정보가 함께 들어가요.',
                trailing: const Icon(
                  Icons.mail_outline,
                  color: AppColors.inkSub,
                ),
                onTap: () => sendFeedback(context, info),
              ),
              _Row(
                title: '오픈소스 라이선스',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.inkMute,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: '챙고',
                  applicationVersion: info?.version,
                  applicationLegalese: kIconAttribution,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  12,
                  AppSizes.screenPadding,
                  0,
                ),
                child: Text(kIconAttribution, style: AppText.caption),
              ),
              if (kDebugMode)
                _Row(
                  title: '타일·위젯 데모 (개발용)',
                  onTap: () => context.push(Routes.devTiles),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Rect _originOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return const Rect.fromLTWH(0, 0, 1, 1);
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSizes.screenPadding,
      24,
      AppSizes.screenPadding,
      4,
    ),
    child: Text(title, style: AppText.sectionLabel),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
          vertical: 10,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.line, width: AppSizes.hairline),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(
                      color: titleColor ?? AppColors.ink,
                    ),
                  ),
                  if (subtitle != null) Text(subtitle!, style: AppText.caption),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Row(
      title: title,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
