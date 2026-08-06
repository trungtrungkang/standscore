import 'package:flutter/material.dart';
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
  final ValueChanged<Score> onRename;
  final ValueChanged<Score> onLabels;
  final ValueChanged<Score> onSplit;
  final ValueChanged<Score> onPages;
  final ValueChanged<Score> onReplace;
  final ValueChanged<Score> onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pieces'),
        actions: [
          TextButton(
            onPressed: onOpenFullScore,
            child: const Text('Open full score'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              root.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: pieces.isEmpty
                ? const Center(child: Text('No pieces yet'))
                : ListView.separated(
                    itemCount: pieces.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final score = pieces[index];
                      final pdf = library.absoluteFileOrNull(score);
                      final document = library.documentFor(score);
                      final origin = scoreOriginLine(
                        extent: score.pageExtent,
                        documentName: null,
                        documentPageCount: document?.pageCount,
                      );
                      final labels = labelNames[score.id] ?? const <String>[];
                      return ListTile(
                        leading: pdf == null || thumbnails == null
                            ? const Icon(Icons.picture_as_pdf_outlined)
                            : ScoreThumbnailTile(
                                thumbnails: thumbnails!,
                                scoreId: score.id,
                                pdf: pdf,
                                pageNumber: score.firstAbsolutePage,
                              ),
                        title: Text(score.title),
                        isThreeLine: labels.isNotEmpty || origin != null,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_recencyLine(score, library)),
                            if (origin != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                ),
                                child: Text(origin),
                              ),
                            if (labels.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                ),
                                child: Text(
                                  labels.join(' · '),
                                  style: Theme.of(context).textTheme.bodySmall,
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
                            const PopupMenuItem(
                              value: 'rename',
                              child: Text('Rename…'),
                            ),
                            const PopupMenuItem(
                              value: 'labels',
                              child: Text('Labels…'),
                            ),
                            if (canSplit(score))
                              const PopupMenuItem(
                                value: 'split',
                                child: Text('Split into pieces…'),
                              ),
                            const PopupMenuItem(
                              value: 'pages',
                              child: Text('Pages…'),
                            ),
                            const PopupMenuItem(
                              value: 'replace',
                              child: Text('Replace PDF…'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete…'),
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

  static String _recencyLine(Score score, ScoreLibrary library) {
    final when = score.lastOpenedAt == null
        ? 'Added ${relativeDay(score.createdAt)}'
        : 'Opened ${relativeDay(score.lastOpenedAt!)}';
    final pages = library.pageCountOf(score);
    if (pages == null) return when;
    return '$when · $pages ${pages == 1 ? 'page' : 'pages'}';
  }
}
