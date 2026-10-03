import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';
import 'app_icon.dart';

/// 하단 탭 4개: 트립 / 세트 / 창고 / 설정. 높이 72 + 기기 하단 안전 영역.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    ('tab_trips', '트립'),
    ('tab_sets', '세트'),
    ('tab_inventory', '창고'),
    ('tab_settings', '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.line, width: AppSizes.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.tabBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _Tab(
                    iconKey: _tabs[i].$1,
                    label: _tabs[i].$2,
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.iconKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String iconKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.inkMute;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(iconKey, size: AppSizes.tabIcon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: (selected ? AppText.tabLabelSelected : AppText.tabLabel)
                    .copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
