import 'package:flutter/material.dart';
import 'package:standscore/pageturn/gesture_map.dart';
import 'package:standscore/pageturn/page_turn_amount.dart';
import 'package:standscore/pageturn/page_turn_animation.dart';
import 'package:standscore/pageturn/page_turn_delay.dart';
import 'package:standscore/pageturn/page_turn_prefs.dart';

Future<void> showPageTurnSettingsSheet({
  required BuildContext context,
  required PageTurnPrefs prefs,
  required ValueChanged<PageTurnPrefs> onChanged,
}) async {
  var current = prefs;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          void update(PageTurnPrefs next) {
            current = next;
            setModalState(() {});
            onChanged(next);
          }

          void updateGesture(GestureMap next) {
            if (!validateGestureMap(next)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Keep at least one gesture set to Show menu / chrome.',
                  ),
                ),
              );
              return;
            }
            update(current.copyWith(gestureMap: next));
          }

          // Cap, not a fixed height: the sheet ends where its content does
          // (Spec 0035).
          final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Page turn',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        Text(
                          'Tap zones',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PageTurnTapMode.values.map((mode) {
                            final selected = current.tapMode == mode;
                            return ChoiceChip(
                              label: Text(_tapModeLabel(mode)),
                              selected: selected,
                              onSelected: (_) =>
                                  update(current.copyWith(tapMode: mode)),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        Text(
                          'Swipe',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SwitchListTile(
                          title: const Text('Swipe left → next'),
                          value: current.swipeLeft,
                          onChanged: (v) =>
                              update(current.copyWith(swipeLeft: v)),
                        ),
                        SwitchListTile(
                          title: const Text('Swipe right → previous'),
                          value: current.swipeRight,
                          onChanged: (v) =>
                              update(current.copyWith(swipeRight: v)),
                        ),
                        SwitchListTile(
                          title: const Text('Swipe up → next'),
                          value: current.swipeUp,
                          onChanged: (v) =>
                              update(current.copyWith(swipeUp: v)),
                        ),
                        SwitchListTile(
                          title: const Text('Swipe down → previous'),
                          value: current.swipeDown,
                          onChanged: (v) =>
                              update(current.copyWith(swipeDown: v)),
                        ),
                        const Divider(height: 32),
                        SwitchListTile(
                          title: const Text('Reverse page-turn direction'),
                          subtitle: const Text(
                            'For books that turn the other way',
                          ),
                          value: current.reverseDirection,
                          onChanged: (v) =>
                              update(current.copyWith(reverseDirection: v)),
                        ),
                        const Divider(height: 32),
                        Text(
                          'Turn amount',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Half page advances ~½ screen in Fit width/height scroll. '
                          'Not the same as Half page layout.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: TurnAmount.values.map((amount) {
                            return ChoiceChip(
                              label: Text(_turnAmountLabel(amount)),
                              selected: current.turnAmount == amount,
                              onSelected: (_) =>
                                  update(current.copyWith(turnAmount: amount)),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        Text(
                          'Animation',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PageTurnAnimationPreset.values.map((
                            preset,
                          ) {
                            return ChoiceChip(
                              label: Text(_animationLabel(preset)),
                              selected: current.animationPreset == preset,
                              onSelected: (_) => update(
                                current.copyWith(animationPreset: preset),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        Text(
                          'Page turn delay',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PageTurnDelayPreset.values.map((preset) {
                            return ChoiceChip(
                              label: Text(_delayLabel(preset)),
                              selected: current.delayPreset == preset,
                              onSelected: (_) =>
                                  update(current.copyWith(delayPreset: preset)),
                            );
                          }).toList(),
                        ),
                        if (current.delayPreset != PageTurnDelayPreset.off) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Apply to',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: PageTurnDelayScope.values.map((scope) {
                              return ChoiceChip(
                                label: Text(_scopeLabel(scope)),
                                selected: current.delayScope == scope,
                                onSelected: (_) =>
                                    update(current.copyWith(delayScope: scope)),
                              );
                            }).toList(),
                          ),
                        ],
                        const Divider(height: 32),
                        Text(
                          'Gestures',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Edge taps are thin strips at the top and bottom — not the '
                          'same as Top/bottom page-turn zones. At least one must be '
                          'Show menu / chrome; that gesture also reveals the toolbar '
                          'in Performance mode. Draw is entered from the toolbar, '
                          'never from a gesture.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        _GestureRow(
                          label: 'Long-press',
                          value: current.gestureMap.longPress,
                          onChanged: (a) => updateGesture(
                            current.gestureMap.copyWith(longPress: a),
                          ),
                        ),
                        _GestureRow(
                          label: 'Top edge',
                          value: current.gestureMap.topEdge,
                          onChanged: (a) => updateGesture(
                            current.gestureMap.copyWith(topEdge: a),
                          ),
                        ),
                        _GestureRow(
                          label: 'Bottom edge',
                          value: current.gestureMap.bottomEdge,
                          onChanged: (a) => updateGesture(
                            current.gestureMap.copyWith(bottomEdge: a),
                          ),
                        ),
                        const Divider(height: 32),
                        Text(
                          'Pedal / keyboard',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bluetooth pedals that send keyboard keys are supported:\n'
                          'Previous — PageUp, ←, ↑, Space\n'
                          'Next — PageDown, →, ↓, Enter',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _GestureRow extends StatelessWidget {
  const _GestureRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final GestureMapAction value;
  final ValueChanged<GestureMapAction> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GestureMapAction.values.map((action) {
              return ChoiceChip(
                label: Text(_gestureActionLabel(action)),
                selected: value == action,
                onSelected: (_) => onChanged(action),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

String _animationLabel(PageTurnAnimationPreset preset) {
  return switch (preset) {
    PageTurnAnimationPreset.off => 'Off',
    PageTurnAnimationPreset.fast => 'Fast',
    PageTurnAnimationPreset.normal => 'Normal',
    PageTurnAnimationPreset.slow => 'Slow',
  };
}

String _delayLabel(PageTurnDelayPreset preset) {
  return switch (preset) {
    PageTurnDelayPreset.off => 'Off',
    PageTurnDelayPreset.ms300 => '0.3s',
    PageTurnDelayPreset.ms500 => '0.5s',
    PageTurnDelayPreset.ms1000 => '1.0s',
  };
}

String _scopeLabel(PageTurnDelayScope scope) {
  return switch (scope) {
    PageTurnDelayScope.all => 'All',
    PageTurnDelayScope.pedalOnly => 'Pedal & keyboard only',
  };
}

String _tapModeLabel(PageTurnTapMode mode) {
  return switch (mode) {
    PageTurnTapMode.leftRight => 'Left / right',
    PageTurnTapMode.topBottom => 'Top / bottom',
    PageTurnTapMode.previous => 'Anywhere → prev',
    PageTurnTapMode.next => 'Anywhere → next',
    PageTurnTapMode.disabled => 'Disabled',
  };
}

String _turnAmountLabel(TurnAmount amount) {
  return switch (amount) {
    TurnAmount.full => 'Full page',
    TurnAmount.half => 'Half page',
  };
}

String _gestureActionLabel(GestureMapAction action) {
  return switch (action) {
    GestureMapAction.showChrome => 'Show menu / chrome',
    GestureMapAction.disabled => 'Off',
  };
}
