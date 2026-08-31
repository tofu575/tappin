import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';

class MemoEditDialog extends HookWidget {
  const MemoEditDialog({super.key, required this.initialText});

  final String initialText;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialText);

    return AlertDialog(
      title: Text(context.l10n.memoEditTitle),
      content: TextField(
        controller: controller,
        maxLines: 1,
        maxLength: Memo.maxLength,
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\n')),
          LengthLimitingTextInputFormatter(Memo.maxLength),
        ],
        decoration: InputDecoration(hintText: context.l10n.memoHint),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
