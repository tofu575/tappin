import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
        maxLines: null,
        keyboardType: TextInputType.multiline,
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
