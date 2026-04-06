import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tappin/domain/models/pin/memo.dart';

const _title = 'メモを編集';
const _hint = 'メモを入力...';
const _cancel = 'キャンセル';
const _save = '保存';

class MemoEditDialog extends HookWidget {
  const MemoEditDialog({super.key, required this.initialText});

  final String initialText;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialText);

    return AlertDialog(
      title: const Text(_title),
      content: TextField(
        controller: controller,
        maxLines: 1,
        maxLength: Memo.maxLength,
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\n')),
          LengthLimitingTextInputFormatter(Memo.maxLength),
        ],
        decoration: const InputDecoration(hintText: _hint),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text(_save),
        ),
      ],
    );
  }
}
