import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score_thumbnails.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/pdf_page_grid.dart';

/// Which boundary a tap on the grid moves.
enum _Edge { first, last }

/// Moving which pages of a book a piece covers (Spec 0052).
///
/// Pops the new PageExtent, or null if nothing was changed. Editing has to
/// exist: a proposal read off a table of contents is wrong in places, and
/// without this screen the only repair would be to delete the piece and import
/// it again — which is exactly how the annotations get lost.
///
/// The same page grid as the split screen, plus a chip saying which end a tap
/// moves. Two taps meaning different things depending on order would be a
/// guessing game; naming the end out loud is not.
class PageExtentScreen extends StatefulWidget {
  const PageExtentScreen({
    super.key,
    required this.scoreTitle,
    required this.pdf,
    required this.documentId,
    required this.pageCount,
    required this.initial,
    this.thumbnails,
  });

  final String scoreTitle;
  final File pdf;
  final String documentId;
  final int pageCount;
  final PageExtent initial;
  final ScoreThumbnails? thumbnails;

  @override
  State<PageExtentScreen> createState() => _PageExtentScreenState();
}

class _PageExtentScreenState extends State<PageExtentScreen> {
  late int _first;
  late int _last;
  _Edge _editing = _Edge.first;

  @override
  void initState() {
    super.initState();
    _first = widget.initial.firstPage.clamp(1, widget.pageCount);
    _last = widget.initial.lastPage.clamp(_first, widget.pageCount);
  }

  PageExtent get _extent => PageExtent(firstPage: _first, lastPage: _last);

  bool get _changed => _extent != widget.initial;

  void _setEdge(int page) {
    setState(() {
      switch (_editing) {
        case _Edge.first:
          _first = page > _last ? _last : page;
          // Picking the start is usually followed by picking the end, and
          // moving the chip along saves the tap that everyone forgets.
          _editing = _Edge.last;
        case _Edge.last:
          _last = page < _first ? _first : page;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pages = _extent.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pageExtentScreenTitle),
        actions: [
          TextButton(
            onPressed: _changed
                ? () => Navigator.of(context).pop(_extent)
                : null,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.pageExtentScreenFirstPage(_first)),
                  selected: _editing == _Edge.first,
                  onSelected: (_) => setState(() => _editing = _Edge.first),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: Text(l10n.pageExtentScreenLastPage(_last)),
                  selected: _editing == _Edge.last,
                  onSelected: (_) => setState(() => _editing = _Edge.last),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.pageCount < 1
                ? Center(child: Text(l10n.pageExtentScreenNoPages))
                : PdfPageGrid(
                    pdf: widget.pdf,
                    pageCount: widget.pageCount,
                    cacheKey: widget.documentId,
                    thumbnails: widget.thumbnails,
                    onTap: _setEdge,
                    isSelected: _extent.contains,
                    badgeFor: (page) {
                      if (page == _first && page == _last) {
                        return l10n.pageExtentScreenBadgeOnly;
                      }
                      if (page == _first) return l10n.pageExtentScreenBadgeFirst;
                      if (page == _last) return l10n.pageExtentScreenBadgeLast;
                      return null;
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pageExtentScreenSummary(widget.scoreTitle, pages),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.pageExtentScreenHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
