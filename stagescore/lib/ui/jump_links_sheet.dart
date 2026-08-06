import 'package:flutter/material.dart';
import 'package:stagescore/jumplink/jump_link.dart';
import 'package:stagescore/jumplink/jump_link_store.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/jump_link_edit_sheet.dart';

Future<void> showJumpLinksSheet({
  required BuildContext context,
  required JumpLinkStore store,
  required int currentPage,
  required int pageCount,
  required ValueChanged<int> onJumpToPage,
  required VoidCallback onChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _JumpLinksSheetBody(
        store: store,
        currentPage: currentPage,
        pageCount: pageCount,
        onJumpToPage: onJumpToPage,
        onChanged: onChanged,
      );
    },
  );
}

class _JumpLinksSheetBody extends StatefulWidget {
  const _JumpLinksSheetBody({
    required this.store,
    required this.currentPage,
    required this.pageCount,
    required this.onJumpToPage,
    required this.onChanged,
  });

  final JumpLinkStore store;
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onJumpToPage;
  final VoidCallback onChanged;

  @override
  State<_JumpLinksSheetBody> createState() => _JumpLinksSheetBodyState();
}

class _JumpLinksSheetBodyState extends State<_JumpLinksSheetBody> {
  List<JumpLink> _items = const [];
  bool _loading = true;

  /// Null = list; non-null = add/edit form in the same sheet.
  JumpLink? _editing;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await widget.store.list();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
    widget.onChanged();
  }

  void _openAdd() {
    if (widget.pageCount < 1) return;
    setState(() {
      _adding = true;
      _editing = null;
    });
  }

  void _openEdit(JumpLink link) {
    setState(() {
      _adding = false;
      _editing = link;
    });
  }

  void _backToList() {
    setState(() {
      _adding = false;
      _editing = null;
    });
  }

  Future<void> _onEditorResult(JumpLinkEditResult result) async {
    if (result.action == JumpLinkEditAction.delete) {
      final id = _editing?.id;
      if (id != null) await widget.store.delete(id);
    } else if (result.action == JumpLinkEditAction.save) {
      final draft = result.link!;
      if (_editing != null) {
        await widget.store.update(draft);
      } else {
        await widget.store.add(
          originPage: draft.originPage,
          destinationPage: draft.destinationPage,
          normRect: draft.normRect,
          colorValue: draft.colorValue,
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.jumpLinksSheetDragHint),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
    _backToList();
    await _reload();
  }

  Future<void> _delete(JumpLink link) async {
    await widget.store.delete(link.id);
    await _reload();
  }

  bool get _inEditor => _adding || _editing != null;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: _inEditor ? _buildEditor() : _buildList(),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    final l10n = AppLocalizations.of(context);
    final existing = _editing;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: JumpLinkEditorForm(
        key: ValueKey(existing?.id ?? 'add'),
        pageCount: widget.pageCount,
        originPage: existing?.originPage ?? widget.currentPage,
        existing: existing,
        leading: IconButton(
          tooltip: l10n.actionBack,
          onPressed: _backToList,
          icon: const Icon(Icons.arrow_back),
        ),
        onCancel: _backToList,
        onResult: _onEditorResult,
      ),
    );
  }

  Widget _buildList() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.jumpLinksSheetTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton.icon(
                onPressed: widget.pageCount < 1 ? null : _openAdd,
                icon: const Icon(Icons.add_link),
                label: Text(l10n.actionAdd),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? Center(
                  child: Text(
                    l10n.jumpLinksSheetEmpty,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final link = _items[index];
                    return ListTile(
                      leading: Icon(
                        Icons.subdirectory_arrow_right,
                        color: link.color,
                      ),
                      title: Text(
                        l10n.jumpLinksSheetRowTitle(
                          link.originPage,
                          link.destinationPage,
                        ),
                      ),
                      subtitle: Text(l10n.jumpLinksSheetRowSubtitle),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onJumpToPage(link.originPage);
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openEdit(link);
                          } else if (value == 'delete') {
                            _delete(link);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l10n.actionEdit),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l10n.actionDelete),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
