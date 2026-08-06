import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/pageorder/page_order.dart';

/// Full-screen PageOrder editor (Spec 0011).
class PageOrderEditorScreen extends StatefulWidget {
  const PageOrderEditorScreen({super.key, required this.initial});

  final PageOrder initial;

  @override
  State<PageOrderEditorScreen> createState() => _PageOrderEditorScreenState();
}

class _PageOrderEditorScreenState extends State<PageOrderEditorScreen> {
  late PageOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.initial;
  }

  String _label(AppLocalizations l10n, PageOrderEntry entry, int index) {
    if (entry.isBlank) return l10n.pageOrderEditorEntryBlank(index + 1);
    return l10n.pageOrderEditorEntryPdfPage(index + 1, entry.sourcePage!);
  }

  void _applyRowAction(int index, String value) {
    // Let the popup route finish disposing before rebuilding the list.
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _order = switch (value) {
          'duplicate' => _order.duplicate(index),
          'blank' => _order.insertBlank(index + 1),
          'remove' => _order.removeAt(index),
          _ => _order,
        };
      });
    });
  }

  Future<void> _reset() async {
    if (_order.isIdentity) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pageOrderEditorResetTitle),
        content: Text(l10n.pageOrderEditorResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.pageOrderEditorReset),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _order = _order.resetToOriginal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pageOrderEditorAppBarTitle),
        actions: [
          TextButton(
            onPressed: _order.isIdentity ? null : _reset,
            child: Text(l10n.pageOrderEditorReset),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_order),
            child: Text(l10n.actionDone),
          ),
        ],
      ),
      body: _order.length == 0
          ? Center(child: Text(l10n.pageOrderEditorNoPages))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: _order.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() => _order = _order.move(oldIndex, newIndex));
              },
              itemBuilder: (context, index) {
                final entry = _order.entries[index];
                return ListTile(
                  key: ValueKey(entry.id),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(_label(l10n, entry, index)),
                  // ExcludeFocus: arrow keys after the ⋯ menu must not hit a
                  // disposing InkWell (deactivated ancestor assertion).
                  trailing: ExcludeFocus(
                    child: PopupMenuButton<String>(
                      onSelected: (value) => _applyRowAction(index, value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Text(l10n.pageOrderEditorDuplicate),
                        ),
                        PopupMenuItem(
                          value: 'blank',
                          child: Text(l10n.pageOrderEditorInsertBlank),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          enabled: _order.length > 1,
                          child: Text(l10n.pageOrderEditorRemove),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
