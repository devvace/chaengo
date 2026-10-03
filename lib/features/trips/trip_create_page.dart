import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../widgets/buttons.dart';
import 'trip_create_state.dart';
import 'trip_format.dart';

/// S02 트립 생성. [트립 만들기] = 세트 아이템 복사 → S03.
class TripCreatePage extends ConsumerStatefulWidget {
  const TripCreatePage({super.key, this.preselectedSetId});

  final String? preselectedSetId;

  @override
  ConsumerState<TripCreatePage> createState() => _TripCreatePageState();
}

class _TripCreatePageState extends ConsumerState<TripCreatePage> {
  final _nameController = TextEditingController();
  var _creating = false;

  TripCreateControllerProvider get _controller =>
      tripCreateControllerProvider(widget.preselectedSetId);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TripCreateUiState state, {required bool start}) async {
    final form = state.form;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? form.start : form.end,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      // 종료일은 시작일 이후만.
      selectableDayPredicate: start ? null : (d) => !d.isBefore(form.start),
    );
    if (picked == null) return;
    final notifier = ref.read(_controller.notifier);
    if (start) {
      final length = form.end.difference(form.start);
      notifier.setDates(picked, picked.add(length), state.sets);
    } else {
      notifier.setDates(form.start, picked, state.sets);
    }
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final form = ref.read(_controller);
      final id = await ref.read(_controller.notifier).create();
      if (!mounted) return;
      // 뒤로 가면 S02가 아니라 S01로 돌아가도록 교체한다.
      // 세트 없이 시작했으면 S03에서 S04를 바로 연다.
      context.pushReplacement(
        Routes.trip(id, openAddSheet: form.setId == null),
      );
    } on StateError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tripCreateUiStateProvider(widget.preselectedSetId));
    final state = async.value;

    // 세트 목록이 처음 들어오면 기본 선택·기본 이름을 채운다.
    if (state != null && !state.form.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(_controller.notifier).initWith(state.sets);
      });
    }
    // 이름이 자동으로 바뀌면 입력칸에도 반영한다.
    ref.listen(_controller.select((f) => f.name), (_, name) {
      if (_nameController.text != name) _nameController.text = name;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('새 트립')),
      body: switch (async) {
        AsyncValue(:final error?) => Center(child: Text('불러오지 못했어요\n$error')),
        AsyncValue(value: final s?) when s.form.initialized => _buildForm(s),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildForm(TripCreateUiState state) {
    final notifier = ref.read(_controller.notifier);
    final form = state.form;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              8,
              AppSizes.screenPadding,
              24,
            ),
            children: [
              Text('트립 이름', style: AppText.sectionLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                onChanged: notifier.setName,
                textInputAction: TextInputAction.done,
                style: AppText.body,
                decoration: const InputDecoration(hintText: '예: 감성캠핑 9월'),
              ),
              const SizedBox(height: 20),
              Text('날짜', style: AppText.sectionLabel),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: '시작',
                      date: form.start,
                      onTap: () => _pickDate(state, start: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateField(
                      label: '종료',
                      date: form.end,
                      onTap: () => _pickDate(state, start: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('기록용이에요. 알림은 없어요.', style: AppText.caption),
              const SizedBox(height: 20),
              Text('세트 선택', style: AppText.sectionLabel),
              const SizedBox(height: 4),
              for (final detail in state.sets)
                _SetOption(
                  key: ValueKey(detail.set.id),
                  title: detail.set.name,
                  subtitle: [
                    '${detail.itemCount}개',
                    if (detail.set.isBuiltIn) '기본 제공',
                  ].join(' · '),
                  selected: form.setId == detail.set.id,
                  onTap: () => notifier.selectSet(detail.set.id, state.sets),
                ),
              _SetOption(
                title: '세트 없이 빈 트립으로 시작',
                subtitle: '만든 뒤 아이템을 바로 추가해요',
                selected: form.setId == null,
                onTap: () => notifier.selectSet(null, state.sets),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.line, width: AppSizes.hairline),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                12,
                AppSizes.screenPadding,
                12,
              ),
              child: PrimaryButton(
                label: '트립 만들기',
                onPressed: state.canCreate && !_creating ? _create : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label ${TripFormat.short(date)}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: AppSizes.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            border: Border.all(color: AppColors.ink, width: AppSizes.border),
          ),
          child: Row(
            children: [
              Text(label, style: AppText.caption),
              const Spacer(),
              Text.rich(withMonoDigits(TripFormat.short(date), AppText.body)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 단일 선택 라디오 행. Material Radio 대신 토큰 색으로 그린다.
class _SetOption extends StatelessWidget {
  const _SetOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// 선택된 라디오의 굵은 링 두께(가운데 흰 점이 남도록).
  static const _radioRing = 6.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.line,
                width: AppSizes.hairline,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.badge,
                height: AppSizes.badge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.ink : AppColors.lineStrong,
                    width: selected ? _radioRing : AppSizes.border,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    Text.rich(withMonoDigits(subtitle, AppText.caption)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
