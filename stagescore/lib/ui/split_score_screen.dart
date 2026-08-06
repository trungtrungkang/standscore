import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stagescore/library/outline_split.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/score_thumbnails.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/pdf_page_grid.dart';
import 'package:stagescore/ui/title_prompt.dart';

/// Marking where each piece of a book begins (Spec 0052).
///
/// Pops the marks to split on, or null if the musician backed out. One mark
/// alone is not a split, so Save waits for a second one.
///
/// A proposal read off the table of contents is a **proposal**, and it has to be
/// asked for: the grid opens unmarked and the outline sits behind one action
/// carrying its own count. Seeding it made a two-entry outline look exactly like
/// a twenty-four-entry one, so the musician had to work out that the proposal
/// was junk before going to look for Clear marks — the hardest part of the job,
/// handed over with nothing to do it with. The count in the button label is that
/// missing evidence: `2` on a long book warns by itself (Spec 0052, G3 #11).
/// Splitting is re-enterable, and [pages] is what makes it safe: a piece can be
/// carved into smaller pieces because the screen never shows, or marks, a page
/// outside the Score it was opened from (Spec 0054).
class SplitScoreScreen extends StatefulWidget {
  const SplitScoreScreen({
    super.key,
    required this.bookTitle,
    required this.pdf,
    required this.documentId,
    required this.pages,
    this.fixedFirstTitle,
    this.thumbnails,
    this.proposals = const <OutlineSplitProposal>[],
    this.initialMarks = const <SplitMark>[],
    this.appBarTitle = 'Split into pieces',
  });

  /// Name the default piece titles are built from — the book when splitting a
  /// whole file, the piece itself when splitting one piece. Passing the book in
  /// both cases would number a second split `Book — 1, 2, 3` all over again,
  /// colliding with the names the first split already handed out.
  final String bookTitle;

  final File pdf;

  /// Thumbnail cache namespace: every piece of one book shares the pictures.
  final String documentId;

  /// Absolute document pages this screen may mark.
  final PageExtent pages;

  /// Non-null to fix a mark on the first page, carrying this title.
  ///
  /// Set when splitting a piece: its opening pages are music the musician chose
  /// to keep and may have written on, so unlike a book's front matter they may
  /// not fall out of every Score here — the screen for changing which pages a
  /// piece covers already exists. The title keeps the piece's own name instead
  /// of renaming it to `<piece> — 1` (Spec 0054, G3 #8 and #9).
  final String? fixedFirstTitle;

  final ScoreThumbnails? thumbnails;

  /// Boundaries and names read off the outline, already flattened and sorted.
  final List<OutlineSplitProposal> proposals;

  /// Marks the grid opens with already checked — "Edit pieces" reopening a
  /// root that already has children, one mark per current piece, so the
  /// musician sees today's boundaries and un-checks or adds to them rather
  /// than starting from a blank grid (Spec 0055 follow-up).
  final List<SplitMark> initialMarks;

  /// App bar title: "Split into pieces" for a first cut, "Edit pieces" when
  /// [initialMarks] seeds the grid from an existing split.
  final String appBarTitle;

  @override
  State<SplitScoreScreen> createState() => _SplitScoreScreenState();
}

class _SplitScoreScreenState extends State<SplitScoreScreen> {
  /// Start page → the name the musician typed, or null to keep the default for
  /// that position. Storing null rather than the default matters: inserting a
  /// mark renumbers every piece after it, and a stored default would then be
  /// the wrong number in the Library forever.
  final Map<int, String?> _titles = {};

  /// What the contents list proposes, minus the entries this file cannot hold.
  /// Held aside rather than applied, and offered with its length shown.
  late final List<OutlineSplitProposal> _proposals;

  bool _proposalsUsed = false;

  @override
  void initState() {
    super.initState();
    _proposals = [
      for (final proposal in widget.proposals)
        if (widget.pages.contains(proposal.startPage)) proposal,
    ];
    for (final mark in widget.initialMarks) {
      if (widget.pages.contains(mark.startPage)) {
        _titles[mark.startPage] = mark.title;
      }
    }
    final fixed = widget.fixedFirstTitle;
    if (fixed != null) _titles[widget.pages.firstPage] = fixed;
  }

  List<int> get _starts => _titles.keys.toList()..sort();

  bool get _canSave => _titles.length > 1;

  bool _isFixed(int page) =>
      widget.fixedFirstTitle != null && page == widget.pages.firstPage;

  /// Pages ahead of the first mark, which belong to no piece: the cover, the
  /// contents page, a preface. Nothing is lost — a page lives in the
  /// PdfDocument, not in a Score, and it takes a mark again at any time. What
  /// forcing a mark on page 1 produced instead was a junk Library row holding
  /// the front matter of every book split this way (Spec 0052, G3 #12).
  ///
  /// Always zero when splitting a piece, because its first page carries a mark
  /// that cannot come off.
  int get _frontMatterCount =>
      _starts.isEmpty ? 0 : _starts.first - widget.pages.firstPage;

  String _titleFor(int start) {
    final typed = _titles[start]?.trim();
    if (typed != null && typed.isNotEmpty) return typed;
    // "<book> — 3" rather than "Untitled": a Library holding twelve rows called
    // Untitled is worse than twelve carrying the name of the book they are in.
    return '${widget.bookTitle} — ${_starts.indexOf(start) + 1}';
  }

  void _toggle(int page) {
    if (_isFixed(page)) return;
    setState(() {
      if (_titles.containsKey(page)) {
        _titles.remove(page);
      } else {
        _titles[page] = null;
      }
    });
  }

  void _useProposals() {
    setState(() {
      _titles
        ..clear()
        ..addEntries(
          _proposals.map((p) => MapEntry(p.startPage, p.title)),
        );
      // The outline may well propose a boundary somewhere else entirely; the
      // fixed mark is not a proposal and does not go away with them.
      final fixed = widget.fixedFirstTitle;
      if (fixed != null) {
        _titles[widget.pages.firstPage] ??= fixed;
      }
      _proposalsUsed = true;
    });
  }

  Future<void> _rename(int page) async {
    if (!_titles.containsKey(page)) return;
    final typed = await promptForTitle(
      context: context,
      title: 'Name this piece',
      initial: _titleFor(page),
    );
    if (typed == null || !mounted) return;
    final trimmed = typed.trim();
    setState(() => _titles[page] = trimmed.isEmpty ? null : trimmed);
  }

  void _clearMarks() {
    setState(() {
      _titles.clear();
      final fixed = widget.fixedFirstTitle;
      if (fixed != null) _titles[widget.pages.firstPage] = fixed;
      // The offer comes back with it: clearing is how someone says the proposal
      // was wrong, not that they never want to see it.
      _proposalsUsed = false;
    });
  }

  void _save() {
    final marks = <SplitMark>[
      for (final start in _starts) (startPage: start, title: _titleFor(start)),
    ];
    Navigator.of(context).pop(marks);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pieces = _titles.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: [
          TextButton(
            // The fixed mark is not a mark anyone put there, so it does not
            // count towards having something to clear.
            onPressed: pieces > (widget.fixedFirstTitle == null ? 0 : 1)
                ? _clearMarks
                : null,
            child: const Text('Clear marks'),
          ),
          TextButton(
            onPressed: _canSave ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: !widget.pages.isValid
          ? const Center(child: Text('This PDF has no pages to split.'))
          : PdfPageGrid(
              pdf: widget.pdf,
              firstPage: widget.pages.firstPage,
              pageCount: widget.pages.length,
              cacheKey: widget.documentId,
              thumbnails: widget.thumbnails,
              onTap: _toggle,
              onLongPress: _rename,
              isSelected: _titles.containsKey,
              badgeFor: (page) => _titles.containsKey(page)
                  ? '${_starts.indexOf(page) + 1}'
                  : null,
              captionFor: (page) =>
                  _titles.containsKey(page) ? _titleFor(page) : null,
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
                switch (pieces) {
                  0 => 'No pieces yet',
                  1 => '1 piece',
                  _ => '$pieces pieces',
                },
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap a page where a new piece begins. '
                'Long-press a marked page to name it.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_frontMatterCount > 0)
                Text(
                  _frontMatterCount == 1
                      ? 'Page ${widget.pages.firstPage} is not in any piece.'
                      : 'Pages ${widget.pages.firstPage}–${_starts.first - 1} '
                            'are not in any piece.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (_proposals.isNotEmpty && !_proposalsUsed) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: _useProposals,
                  child: Text(
                    _proposals.length == 1
                        ? 'Use contents list (1 entry)'
                        : 'Use contents list (${_proposals.length} entries)',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
