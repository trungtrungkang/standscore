import 'package:flutter/material.dart';
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

  String _label(PageOrderEntry entry, int index) {
    if (entry.isBlank) return '${index + 1}. Blank';
    return '${index + 1}. PDF page ${entry.sourcePage}';
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to original?'),
        content: const Text(
          'Restore the PDF page order and remove blanks and duplicates?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page order'),
        actions: [
          TextButton(
            onPressed: _order.isIdentity ? null : _reset,
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_order),
            child: const Text('Done'),
          ),
        ],
      ),
      body: _order.length == 0
          ? const Center(child: Text('No pages'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _order.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() => _order = _order.move(oldIndex, newIndex));
              },
              itemBuilder: (context, index) {
                final entry = _order.entries[index];
                return ListTile(
                  key: ValueKey(entry.id),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(_label(entry, index)),
                  // ExcludeFocus: arrow keys after the ⋯ menu must not hit a
                  // disposing InkWell (deactivated ancestor assertion).
                  trailing: ExcludeFocus(
                    child: PopupMenuButton<String>(
                      onSelected: (value) => _applyRowAction(index, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Text('Duplicate'),
                        ),
                        const PopupMenuItem(
                          value: 'blank',
                          child: Text('Insert blank'),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          enabled: _order.length > 1,
                          child: const Text('Remove'),
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
