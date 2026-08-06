import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stagescore/library/score_thumbnails.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:stagescore/ui/score_thumbnail_tile.dart';

/// Width a page card aims for, so a phone lays out two columns and a tablet
/// more. Measured against the narrowest supported phone, not a spacing step.
const double kPageCardExtent = 160;

/// Page card proportions: a portrait page plus room for a number and a name.
const double kPageCardAspectRatio = 0.62;

/// A grid of the pages of one PDF, for deciding things about pages (Spec 0052).
///
/// A grid rather than a pair of page-number fields, because a musician
/// recognises where a piece begins by **seeing the title on the page**, not by
/// remembering that it was page 47. Spec 0048 had already worked out this shape
/// for the PageOrder editor; it applies unchanged here.
///
/// Thumbnails come from the same lazily-filled, disk-backed cache the Library
/// rows use, so a 200-page book renders the dozen cards on screen and no more.
class PdfPageGrid extends StatelessWidget {
  const PdfPageGrid({
    super.key,
    required this.pdf,
    required this.pageCount,
    this.firstPage = 1,
    required this.cacheKey,
    required this.thumbnails,
    required this.onTap,
    this.isSelected,
    this.badgeFor,
    this.captionFor,
    this.onLongPress,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final File pdf;

  /// How many cards to draw, starting at [firstPage].
  final int pageCount;

  /// Absolute document page of the first card.
  ///
  /// Off by default, and the Pages screen must leave it off: moving an extent's
  /// edge means reaching outside the extent, so that screen needs the whole
  /// file. Splitting one piece is the case that needs a window (Spec 0054).
  final int firstPage;

  /// Namespace for cached page thumbnails — the PdfDocument id, so every piece
  /// of one book shares the pictures instead of rendering its own copy.
  final String cacheKey;

  final ScoreThumbnails? thumbnails;

  /// Absolute 1-based document page, in every callback below.
  final void Function(int page) onTap;
  final void Function(int page)? onLongPress;
  final bool Function(int page)? isSelected;

  /// A short marker drawn over the page, e.g. the number of the piece starting
  /// there.
  final String? Function(int page)? badgeFor;

  /// A line under the page number, e.g. the name of the piece starting there.
  final String? Function(int page)? captionFor;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: kPageCardExtent,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: kPageCardAspectRatio,
      ),
      itemCount: pageCount,
      itemBuilder: (context, index) {
        final page = firstPage + index;
        return _PageCard(
          page: page,
          pdf: pdf,
          cacheKey: cacheKey,
          thumbnails: thumbnails,
          selected: isSelected?.call(page) ?? false,
          badge: badgeFor?.call(page),
          caption: captionFor?.call(page),
          onTap: () => onTap(page),
          onLongPress: onLongPress == null ? null : () => onLongPress!(page),
        );
      },
    );
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({
    required this.page,
    required this.pdf,
    required this.cacheKey,
    required this.thumbnails,
    required this.selected,
    required this.badge,
    required this.caption,
    required this.onTap,
    required this.onLongPress,
  });

  final int page;
  final File pdf;
  final String cacheKey;
  final ScoreThumbnails? thumbnails;
  final bool selected;
  final String? badge;
  final String? caption;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = caption;
    return Semantics(
      selected: selected,
      button: true,
      label: label == null ? 'Page $page' : 'Page $page, $label',
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LayoutBuilder(
                        builder: (context, box) => ScoreThumbnailTile(
                          thumbnails: thumbnails,
                          scoreId: cacheKey,
                          pdf: pdf,
                          pageNumber: page,
                          width: box.maxWidth,
                          height: box.maxHeight,
                        ),
                      ),
                      if (badge != null)
                        Align(
                          alignment: Alignment.topLeft,
                          child: _Badge(badge!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '$page',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (label != null)
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}
