import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';
import 'buttons.dart';
import 'qty_stepper.dart';

/// 롱프레스 수량 시트(1–99). 확인하면 수량, 닫으면 null. S03·S06 공용.
Future<int?> showQtySheet(
  BuildContext context, {
  required String itemName,
  required int initial,
}) => showModalBottomSheet<int>(
  context: context,
  showDragHandle: true,
  builder: (context) => _QtySheet(itemName: itemName, initial: initial),
);

class _QtySheet extends StatefulWidget {
  const _QtySheet({required this.itemName, required this.initial});

  final String itemName;
  final int initial;

  @override
  State<_QtySheet> createState() => _QtySheetState();
}

class _QtySheetState extends State<_QtySheet> {
  late int _qty = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          0,
          AppSizes.screenPadding,
          12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${widget.itemName} 수량', style: AppText.cardTitle),
            const SizedBox(height: 16),
            Center(
              child: QtyStepper(
                value: _qty,
                onChanged: (v) => setState(() => _qty = v),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: '확인',
              onPressed: () => Navigator.of(context).pop(_qty),
            ),
          ],
        ),
      ),
    );
  }
}
