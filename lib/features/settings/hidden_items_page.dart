import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/providers.dart';
import '../../widgets/small_icon_tile.dart';
import 'settings_state.dart';

/// S09 > 숨김 아이템 보기. 행을 탭하면 바로 복구된다.
class HiddenItemsPage extends ConsumerWidget {
  const HiddenItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(hiddenItemsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('숨김 아이템')),
      body: hidden.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('불러오지 못했어요\n$e')),
        data: (items) => items.isEmpty
            ? Center(child: Text('숨긴 아이템이 없어요', style: AppText.caption))
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.screenPadding,
                      4,
                      AppSizes.screenPadding,
                      8,
                    ),
                    child: Text('탭하면 창고·세트에 다시 보여요.', style: AppText.caption),
                  ),
                  for (final item in items)
                    InkWell(
                      key: ValueKey(item.id),
                      onTap: () async {
                        await ref
                            .read(itemDaoProvider)
                            .setHidden(item.id, hidden: false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text('‘${item.name}’ 복구')),
                            );
                        }
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: AppSizes.buttonHeight,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.screenPadding,
                          vertical: 8,
                        ),
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
                            SmallIconTile(
                              glyph: item.glyph,
                              tileSize: AppSizes.rowTile,
                              iconSize: AppSizes.rowIcon,
                              muted: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: AppText.body),
                                  Text(
                                    item.category.label,
                                    style: AppText.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text('복구', style: AppText.chipSelected),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
