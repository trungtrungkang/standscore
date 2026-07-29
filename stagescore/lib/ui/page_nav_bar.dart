import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stagescore/pageturn/page_jump.dart';
import 'package:stagescore/theme/app_tokens.dart';

/// Height of the bar's content, above any home-indicator inset.
///
/// One scrubber row, so it sits at the minimum tap target rather than the
/// toolbar height — the AppBar above it is the one carrying controls (0034).
const double kPageNavBarHeight = kMinInteractiveDimension;

/// Dead space kept below the scrubber, on top of any home-indicator inset.
///
/// The bottom strip of a phone belongs to the OS: a horizontal drag that
/// starts there switches apps instead of moving the scrubber. Sitting flush on
/// the safe area is close enough to lose the drag, which is what happened when
/// 0034 shortened this bar, so the gap it used to have as padding is now
/// explicit.
const double kPageNavBarGestureGap = 20;

/// Compact bottom chrome: page label, scrubber, jump-to-page (Spec 0009).
class PageNavBar extends StatelessWidget {
  const PageNavBar({
    super.key,
    required this.pageNumber,
    required this.pageCount,
    required this.onJumpToPage,
    this.onPrevPage,
    this.onNextPage,
    this.trailing = const <Widget>[],
    this.bottomGestureGap = true,
    this.avoidNotches = true,
  });

  final int pageNumber;
  final int pageCount;
  final ValueChanged<int> onJumpToPage;
  final VoidCallback? onPrevPage;
  final VoidCallback? onNextPage;

  /// Extra controls riding in this row, right of the next-page chevron.
  ///
  /// A screen too short to afford a second row of bottom chrome puts the
  /// ScoreMenuQuickBar's shortcuts here instead (Spec 0043 revision 3), which
  /// is only affordable because a screen that short is a wide one: a phone in
  /// landscape still leaves the scrubber 508 pt.
  final List<Widget> trailing;

  /// Whether to keep [kPageNavBarGestureGap] below the scrubber.
  ///
  /// The gap exists because a horizontal drag flush on the OS's own bottom
  /// strip switches apps instead of moving the scrubber. When another bar sits
  /// below this one it is that bar's edge the OS owns, so the gap here is dead
  /// space in the middle of the chrome — 20 pt of a landscape phone's 393.
  final bool bottomGestureGap;

  /// When false, sit edge-to-edge over the home indicator (Spec 0032).
  final bool avoidNotches;

  @override
  Widget build(BuildContext context) {
    if (pageCount < 1) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final max = pageCount.toDouble();
    final value = pageNumber.clamp(1, pageCount).toDouble();

    final canGoPrev = pageNumber > 1;
    final canGoNext = pageNumber < pageCount;

    return ExcludeFocus(
      child: Material(
        elevation: 2,
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          left: avoidNotches,
          right: avoidNotches,
          bottom: avoidNotches,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xs,
              0,
              AppSpacing.xs,
              bottomGestureGap ? kPageNavBarGestureGap : 0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous page',
                  onPressed: canGoPrev
                      ? () {
                          if (onPrevPage != null) {
                            onPrevPage!();
                          } else {
                            onJumpToPage(pageNumber - 1);
                          }
                        }
                      : null,
                ),
                TextButton(
                  onPressed: () => _onJumpPressed(context),
                  child: Text('$pageNumber / $pageCount'),
                ),
                Expanded(
                  // Slider fills any bounded height it is given, which would
                  // stretch the bar over the Score (Spec 0034).
                  child: SizedBox(
                    height: kPageNavBarHeight,
                    child: Slider(
                      min: 1,
                      max: max,
                      divisions: pageCount > 1 ? pageCount - 1 : null,
                      value: value,
                      label: '$pageNumber',
                      onChanged: (v) => onJumpToPage(v.round()),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next page',
                  onPressed: canGoNext
                      ? () {
                          if (onNextPage != null) {
                            onNextPage!();
                          } else {
                            onJumpToPage(pageNumber + 1);
                          }
                        }
                      : null,
                ),
                ...trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onJumpPressed(BuildContext context) async {
    final result = await showJumpToPageDialog(
      context: context,
      pageNumber: pageNumber,
      pageCount: pageCount,
    );
    if (result == null || !context.mounted) return;
    onJumpToPage(result.page);
    if (result.wasClamped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumped to page ${result.page} (valid range 1–$pageCount).',
          ),
        ),
      );
    }
  }
}

/// Shows jump dialog; returns clamped page, or null if cancelled.
Future<({int page, bool wasClamped})?> showJumpToPageDialog({
  required BuildContext context,
  required int pageNumber,
  required int pageCount,
}) {
  return showDialog<({int page, bool wasClamped})>(
    context: context,
    builder: (context) =>
        _JumpToPageDialog(pageNumber: pageNumber, pageCount: pageCount),
  );
}

class _JumpToPageDialog extends StatefulWidget {
  const _JumpToPageDialog({required this.pageNumber, required this.pageCount});

  final int pageNumber;
  final int pageCount;

  @override
  State<_JumpToPageDialog> createState() => _JumpToPageDialogState();
}

class _JumpToPageDialogState extends State<_JumpToPageDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.pageNumber}',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = parsePageNumber(_controller.text);
    if (parsed == null) return;
    final clamped = clampPageNumber(parsed, widget.pageCount);
    Navigator.of(context).pop((page: clamped, wasClamped: clamped != parsed));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Go to page'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: 'Page (1–${widget.pageCount})'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Go')),
      ],
    );
  }
}
