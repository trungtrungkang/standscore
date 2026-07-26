import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:standscore/pageturn/page_jump.dart';

/// Compact bottom chrome: page label, scrubber, jump-to-page (Spec 0009).
class PageNavBar extends StatelessWidget {
  const PageNavBar({
    super.key,
    required this.pageNumber,
    required this.pageCount,
    required this.onJumpToPage,
    this.avoidNotches = true,
  });

  final int pageNumber;
  final int pageCount;
  final ValueChanged<int> onJumpToPage;

  /// When false, sit edge-to-edge over the home indicator (Spec 0032).
  final bool avoidNotches;

  @override
  Widget build(BuildContext context) {
    if (pageCount < 1) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final max = pageCount.toDouble();
    final value = pageNumber.clamp(1, pageCount).toDouble();

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
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => _onJumpPressed(context),
                  child: Text('$pageNumber / $pageCount'),
                ),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: max,
                    divisions: pageCount > 1 ? pageCount - 1 : null,
                    value: value,
                    label: '$pageNumber',
                    onChanged: (v) => onJumpToPage(v.round()),
                  ),
                ),
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
    builder: (context) => _JumpToPageDialog(
      pageNumber: pageNumber,
      pageCount: pageCount,
    ),
  );
}

class _JumpToPageDialog extends StatefulWidget {
  const _JumpToPageDialog({
    required this.pageNumber,
    required this.pageCount,
  });

  final int pageNumber;
  final int pageCount;

  @override
  State<_JumpToPageDialog> createState() => _JumpToPageDialogState();
}

class _JumpToPageDialogState extends State<_JumpToPageDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.pageNumber}');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = parsePageNumber(_controller.text);
    if (parsed == null) return;
    final clamped = clampPageNumber(parsed, widget.pageCount);
    Navigator.of(context).pop((
      page: clamped,
      wasClamped: clamped != parsed,
    ));
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
        decoration: InputDecoration(
          labelText: 'Page (1–${widget.pageCount})',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Go'),
        ),
      ],
    );
  }
}
