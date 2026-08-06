import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';

/// Asks for a title, pre-filled with [initial]; null if cancelled.
///
/// Shared by everything renameable — Bookmarks (0010) and Scores (0040) — so
/// renaming feels the same wherever it happens. Returns the raw text: what an
/// empty answer means is the caller's business (a Bookmark falls back to its
/// page number, a Score keeps the title it had).
Future<String?> promptForTitle({
  required BuildContext context,
  required String title,
  required String initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TitlePromptDialog(title: title, initial: initial),
  );
}

/// Owns its [TextEditingController] so dispose runs after the route unmounts.
class _TitlePromptDialog extends StatefulWidget {
  const _TitlePromptDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_TitlePromptDialog> createState() => _TitlePromptDialogState();
}

class _TitlePromptDialogState extends State<_TitlePromptDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.commonTitleLabel),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }
}
