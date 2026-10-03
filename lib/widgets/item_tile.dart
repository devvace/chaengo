import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';
import '../domain/models/item.dart';
import 'item_glyph_view.dart';
import 'dashed_border.dart';
import 'qty_badge.dart';

/// S03 트립 체크의 타일 상태(챙김 여부).
enum CheckTileState { unpacked, packed, excluded }

/// 아이템 타일 76×76 + 아래 라벨.
///
/// 두 화면의 문법을 섞지 않도록 생성자를 나눈다.
/// - [ItemTile.check]: S03. 챙김 = 그린 채움, 제외 = 점선 + 0.4 투명.
/// - [ItemTile.edit]: S06. 담김 = 2px ink 테두리 + surface, 안 담김 = 점선 회색.
class ItemTile extends StatelessWidget {
  const ItemTile.check({
    super.key,
    required this.label,
    required this.glyph,
    required CheckTileState state,
    this.qty = 1,
    this.onTap,
    this.onLongPress,
  }) : _checkState = state,
       included = null;

  const ItemTile.edit({
    super.key,
    required this.label,
    required this.glyph,
    required bool this.included,
    this.qty = 1,
    this.onTap,
    this.onLongPress,
  }) : _checkState = null;

  final String label;
  final ItemGlyph glyph;
  final int qty;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final CheckTileState? _checkState;

  /// S06 담김 여부. [ItemTile.check]이면 null.
  final bool? included;

  /// 제외 타일은 탭에 반응하지 않는다(롱프레스로만 복귀).
  bool get _tapEnabled => _checkState != CheckTileState.excluded;

  @override
  Widget build(BuildContext context) {
    final look = _checkState != null
        ? _checkLook(_checkState)
        : _editLook(included!);

    Widget tile = SizedBox.square(
      dimension: AppSizes.tile,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: look.box),
          Center(
            child: ItemGlyphView(
              glyph,
              size: AppSizes.tileIcon,
              color: look.iconColor,
            ),
          ),
          if (look.badge != null)
            Positioned(
              top: AppSizes.badgeOffset,
              right: AppSizes.badgeOffset,
              child: look.badge!,
            ),
        ],
      ),
    );

    // 원본 CSS는 투명도를 타일 박스에만 준다(라벨은 inkMute + 취소선).
    if (_checkState == CheckTileState.excluded) {
      tile = Opacity(opacity: AppSizes.excludedOpacity, child: tile);
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: look.labelStyle,
        ),
      ],
    );

    return Semantics(
      button: true,
      label: _semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tapEnabled ? onTap : null,
        onLongPress: onLongPress,
        child: content,
      ),
    );
  }

  String get _semanticsLabel {
    final state = switch (_checkState) {
      CheckTileState.unpacked => '안 챙김',
      CheckTileState.packed => '챙김',
      CheckTileState.excluded => '제외',
      null => included! ? '담김' : '안 담김',
    };
    return qty > 1 ? '$label $qty개, $state' : '$label, $state';
  }

  _TileLook _checkLook(CheckTileState state) {
    switch (state) {
      case CheckTileState.unpacked:
        return _TileLook(
          box: _solidBox(fill: AppColors.bg, border: AppColors.lineStrong),
          iconColor: AppColors.ink,
          labelStyle: AppText.tileLabel,
          badge: qty > 1 ? QtyBadge.outlined(qty) : null,
        );
      case CheckTileState.packed:
        return _TileLook(
          box: _solidBox(fill: AppColors.done, border: AppColors.done),
          iconColor: AppColors.bg,
          labelStyle: AppText.tileLabel,
          // 결정(2026-10-03): 이번 버전은 챙김 타일에 체크만 표시하고
          // 수량 뱃지는 숨긴다(같은 우상단 자리).
          badge: const _CheckBadge(),
        );
      case CheckTileState.excluded:
        return _TileLook(
          box: _dashedBox(color: AppColors.lineStrong),
          iconColor: AppColors.ink,
          labelStyle: AppText.tileLabel.copyWith(
            color: AppColors.inkMute,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.inkMute,
          ),
        );
    }
  }

  _TileLook _editLook(bool included) {
    if (included) {
      return _TileLook(
        box: _solidBox(
          fill: AppColors.surface,
          border: AppColors.ink,
          width: AppSizes.borderStrong,
        ),
        iconColor: AppColors.ink,
        labelStyle: AppText.tileLabelStrong,
        badge: qty > 1 ? QtyBadge.filled(qty) : null,
      );
    }
    return _TileLook(
      box: _dashedBox(color: AppColors.dashed),
      iconColor: AppColors.inkMute,
      labelStyle: AppText.tileLabel.copyWith(color: AppColors.inkMute),
    );
  }

  static Widget _solidBox({
    required Color fill,
    required Color border,
    double width = AppSizes.border,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSizes.tileRadius),
        border: Border.all(color: border, width: width),
      ),
    );
  }

  static Widget _dashedBox({required Color color}) {
    return DashedRRectBorder(
      color: color,
      strokeWidth: AppSizes.border,
      radius: AppSizes.tileRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(AppSizes.tileRadius),
        ),
      ),
    );
  }
}

class _TileLook {
  const _TileLook({
    required this.box,
    required this.iconColor,
    required this.labelStyle,
    this.badge,
  });

  final Widget box;
  final Color iconColor;
  final TextStyle labelStyle;
  final Widget? badge;
}

/// S03 챙김 타일 우상단의 ink 원 + 백색 체크.
class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.badge,
      height: AppSizes.badge,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const CustomPaint(
        size: Size.square(12),
        painter: _CheckMarkPainter(),
      ),
    );
  }
}

/// 하이파이 원본의 체크 경로(M5 12l5 5 9-10, 24 기준)를 12px로 그린다.
class _CheckMarkPainter extends CustomPainter {
  const _CheckMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path()
      ..moveTo(5 * s, 12 * s)
      ..lineTo(10 * s, 17 * s)
      ..lineTo(19 * s, 7 * s);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.bg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckMarkPainter oldDelegate) => false;
}
