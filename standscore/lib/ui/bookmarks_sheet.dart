import 'package:flutter/material.dart';
import 'package:standscore/bookmark/bookmark.dart';
import 'package:standscore/bookmark/bookmark_store.dart';
import 'package:standscore/ui/title_prompt.dart';

Future<void> showBookmarksSheet({
  required BuildContext context,
  required BookmarkStore store,
  required int currentPage,
  required ValueChanged<int> onJumpToPage,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return _BookmarksSheetBody(
        store: store,
        currentPage: currentPage,
        onJumpToPage: onJumpToPage,
      );
    },
  );
}

class _BookmarksSheetBody extends StatefulWidget {
  const _BookmarksSheetBody({
    required this.store,
    required this.currentPage,
    required this.onJumpToPage,
  });

  final BookmarkStore store;
  final int currentPage;
  final ValueChanged<int> onJumpToPage;

  @override
  State<_BookmarksSheetBody> createState() => _BookmarksSheetBodyState();
}

class _BookmarksSheetBodyState extends State<_BookmarksSheetBody> {
  List<Bookmark> _items = const [];
  bool _loading = true;

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
  }

  Future<void> _add() async {
    final title = await promptForTitle(
      context: context,
      title: 'Add bookmark',
      initial: 'Page ${widget.currentPage}',
    );
    if (title == null) return;
    await widget.store.add(title: title, pageNumber: widget.currentPage);
    await _reload();
  }

  Future<void> _rename(Bookmark bookmark) async {
    final title = await promptForTitle(
      context: context,
      title: 'Rename bookmark',
      initial: bookmark.title,
    );
    if (title == null) return;
    await widget.store.rename(bookmark.id, title);
    await _reload();
  }

  Future<void> _delete(Bookmark bookmark) async {
    await widget.store.delete(bookmark.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bookmarks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _add,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Add'),
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
                          'No bookmarks yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final bookmark = _items[index];
                          return ListTile(
                            leading: const Icon(Icons.bookmark_outline),
                            title: Text(bookmark.title),
                            subtitle: Text('Page ${bookmark.pageNumber}'),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onJumpToPage(bookmark.pageNumber);
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'rename') {
                                  _rename(bookmark);
                                } else if (value == 'delete') {
                                  _delete(bookmark);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
