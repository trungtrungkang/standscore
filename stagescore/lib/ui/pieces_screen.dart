import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/library/relative_day.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/library/score_library.dart';
import 'package:stagescore/library/score_origin.dart';
import 'package:stagescore/library/score_thumbnails.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/score_thumbnail_tile.dart';

/// Drill-in list of child Scores under one root (Spec 0055).
class PiecesScreen extends StatelessWidget {
  const PiecesScreen({
    super.key,
    required this.root,
    required this.pieces,
    required this.library,
    required this.thumbnails,
    required this.labelNames,
    required this.canSplit,
    required this.onOpenPiece,
    required this.onOpenFullScore,
    required this.onEditPieces,
    required this.onRename,
    required this.onLabels,
    required this.onSplit,
    required this.onPages,
    required this.onReplace,
    required this.onDelete,
  });

  final Score root;
  final List<Score> pieces;
  final ScoreLibrary library;
  final ScoreThumbnails? thumbnails;
  final Map<String, List<String>> labelNames;
  final bool Function(Score score) canSplit;
  final ValueChanged<Score> onOpenPiece;
  final VoidCallback onOpenFullScore;

  /// Redraw where this root's pieces begin, seeded from today's boundaries
  /// (Spec 0055 follow-up "Edit pieces") — reachable here too, not only from
  /// the Library row's own "…", since this screen is where the pieces
  /// actually live.
  final VoidCallback onEditPieces;

  final ValueChanged<Score> onRename;
  final ValueChanged<Score> onLabels;
  final ValueChanged<Score> onSplit;
  final ValueChanged<Score> onPages;
  final ValueChanged<Score> onReplace;
  final ValueChanged<Score> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(root.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit_pieces':
                  onEditPieces();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_pieces',
                child: Text(l10n.piecesScreenEditPieces),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BookSummary(
            root: root,
            pieceCount: pieces.length,
            library: library,
            thumbnails: thumbnails,
            onOpenFullScore: onOpenFullScore,
          ),
          const Divider(height: 1),
          Expanded(
            child: pieces.isEmpty
                ? Center(child: Text(l10n.piecesScreenNoPieces))
                : ListView.separated(
                    itemCount: pieces.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final score = pieces[index];
                      final pdf = library.absoluteFileOrNull(score);
                      final document = library.documentFor(score);
                      final origin = scoreOriginLine(
                        l10n: l10n,
                        extent: score.pageExtent,
                        documentName: null,
                        documentPageCount: document?.pageCount,
                      );
                      final labels = labelNames[score.id] ?? const <String>[];
                      return ListTile(
                        leading: _PieceLeading(
                          index: index + 1,
                          pdf: pdf,
                          thumbnails: thumbnails,
                          scoreId: score.id,
                          pageNumber: score.firstAbsolutePage,
                        ),
                        title: Text(score.title),
                        isThreeLine: labels.isNotEmpty || origin != null,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Which pages this piece covers matters more here
                            // than when it was last opened, so it leads.
                            if (origin != null) Text(origin),
                            Padding(
                              padding: EdgeInsets.only(
                                top: origin != null ? AppSpacing.xs : 0,
                              ),
                              child: Text(
                                _recencyLine(
                                  score,
                                  library,
                                  l10n,
                                  includePageCount: origin == null,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (labels.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                ),
                                child: Text(
                                  labels.join(' · '),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => onOpenPiece(score),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'rename':
                                onRename(score);
                              case 'labels':
                                onLabels(score);
                              case 'split':
                                onSplit(score);
                              case 'pages':
                                onPages(score);
                              case 'replace':
                                onReplace(score);
                              case 'delete':
                                onDelete(score);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text(l10n.piecesScreenRename),
                            ),
                            PopupMenuItem(
                              value: 'labels',
                              child: Text(l10n.piecesScreenLabels),
                            ),
                            if (canSplit(score))
                              PopupMenuItem(
                                value: 'split',
                                child: Text(l10n.piecesScreenSplitIntoPieces),
                              ),
                            PopupMenuItem(
                              value: 'pages',
                              child: Text(l10n.piecesScreenPages),
                            ),
                            PopupMenuItem(
                              value: 'replace',
                              child: Text(l10n.piecesScreenReplacePdf),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.piecesScreenDelete),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// "Opened today · 4 pages" — when it was last played, and (only when
  /// nothing else on the row already says so) how long it is.
  static String _recencyLine(
    Score score,
    ScoreLibrary library,
    AppLocalizations l10n, {
    required bool includePageCount,
  }) {
    final when = score.lastOpenedAt == null
        ? l10n.piecesScreenAdded(relativeDay(l10n, score.createdAt))
        : l10n.piecesScreenOpened(relativeDay(l10n, score.lastOpenedAt!));
    if (!includePageCount) return when;
    final pages = library.pageCountOf(score);
    if (pages == null) return when;
    return l10n.piecesScreenRecencyWithPages(when, pages);
  }
}

/// Cover + "N pieces · M pages" + the way back to the whole file.
///
/// Its own row rather than folded into the AppBar: the title already lives
/// there, and a book title long enough to need an ellipsis would collide
/// with an action button crammed in beside it.
class _BookSummary extends StatelessWidget {
  const _BookSummary({
    required this.root,
    required this.pieceCount,
    required this.library,
    required this.thumbnails,
    required this.onOpenFullScore,
  });

  final Score root;
  final int pieceCount;
  final ScoreLibrary library;
  final ScoreThumbnails? thumbnails;
  final VoidCallback onOpenFullScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pdf = library.absoluteFileOrNull(root);
    final totalPages = library.pageCountOf(root);
    final summary = [
      l10n.piecesScreenPieceCount(pieceCount),
      if (totalPages != null) l10n.piecesScreenPageCount(totalPages),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          pdf == null || thumbnails == null
              ? const Icon(Icons.picture_as_pdf_outlined, size: 40)
              : ScoreThumbnailTile(
                  thumbnails: thumbnails,
                  scoreId: root.id,
                  pdf: pdf,
                ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    visualDensity: VisualDensity.compact,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: onOpenFullScore,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(l10n.piecesScreenOpenFullScore),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail plus a small ordinal badge — orientation in a book that can hold
/// dozens of pieces, without spending a whole line of subtitle text on it.
class _PieceLeading extends StatelessWidget {
  const _PieceLeading({
    required this.index,
    required this.pdf,
    required this.thumbnails,
    required this.scoreId,
    required this.pageNumber,
  });

  final int index;
  final File? pdf;
  final ScoreThumbnails? thumbnails;
  final String scoreId;
  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbnail = pdf == null || thumbnails == null
        ? const Icon(Icons.picture_as_pdf_outlined)
        : ScoreThumbnailTile(
            thumbnails: thumbnails!,
            scoreId: scoreId,
            pdf: pdf!,
            pageNumber: pageNumber,
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        thumbnail,
        Positioned(
          right: 1,
          bottom: 1,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 10,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
