import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 검색 입력. 자동 포커스하지 않는다(키보드 강제 노출 방지).
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onChanged, this.hint = '검색'});

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.inkMute),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: '지우기',
                  icon: const Icon(Icons.close, color: AppColors.inkMute),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
