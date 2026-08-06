import 'package:flutter/material.dart';
import 'package:stagescore/l10n/gen/app_localizations.dart';
import 'package:stagescore/layout/pdf_layout_mode.dart';
import 'package:stagescore/pageturn/gesture_map.dart';
import 'package:stagescore/pageturn/layout_navigation.dart';
import 'package:stagescore/pageturn/page_turn_amount.dart';
import 'package:stagescore/pageturn/page_turn_animation.dart';
import 'package:stagescore/pageturn/page_turn_delay.dart';
import 'package:stagescore/pageturn/page_turn_prefs.dart';
import 'package:stagescore/theme/app_tokens.dart';

Future<void> showPageTurnSettingsSheet({
  required BuildContext context,
  required PageTurnPrefs prefs,
  required ValueChanged<PageTurnPrefs> onChanged,

  /// The layout in force, already resolved: the sheet describes what Match
  /// layout means here and hides what this layout ignores (Spec 0041).
  PdfLayoutMode layoutMode = PdfLayoutMode.single,
}) async {
  var current = prefs;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final l10n = AppLocalizations.of(context);
          void update(PageTurnPrefs next) {
            current = next;
            setModalState(() {});
            onChanged(next);
          }

          void updateGesture(GestureMap next) {
            if (!validateGestureMap(next)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.pageTurnSettingsSheetGestureWarning),
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      0,
                      AppSpacing.xs,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: Text(
                              l10n.pageTurnSettingsSheetTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.actionDone),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xl,
                      ),
                      children: [
                        Text(
                          l10n.pageTurnSettingsSheetTapZones,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.pageTurnSettingsSheetTapZonesHint(
                            layoutMode.label(l10n),
                            navigationHintFor(l10n, layoutMode, current),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PageTurnTapMode.values.map((mode) {
                            final selected = current.tapMode == mode;
                            return ChoiceChip(
                              label: Text(_tapModeLabel(l10n, mode)),
                              selected: selected,
                              onSelected: (_) =>
                                  update(current.copyWith(tapMode: mode)),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        Text(
                          l10n.pageTurnSettingsSheetSwipe,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SwitchListTile(
                          title: Text(l10n.pageTurnSettingsSheetMatchLayout),
                          subtitle: Text(
                            l10n.pageTurnSettingsSheetMatchLayoutSubtitle,
                          ),
                          value: current.swipeMode == SwipeMode.matchLayout,
                          onChanged: (v) => update(
                            current.copyWith(
                              swipeMode: v
                                  ? SwipeMode.matchLayout
                                  : SwipeMode.custom,
                            ),
                          ),
                        ),
                        if (current.swipeMode == SwipeMode.custom) ...[
                          SwitchListTile(
                            title: Text(
                              l10n.pageTurnSettingsSheetSwipeLeftNext,
                            ),
                            value: current.swipeLeft,
                            onChanged: (v) =>
                                update(current.copyWith(swipeLeft: v)),
                          ),
                          SwitchListTile(
                            title: Text(
                              l10n.pageTurnSettingsSheetSwipeRightPrevious,
                            ),
                            value: current.swipeRight,
                            onChanged: (v) =>
                                update(current.copyWith(swipeRight: v)),
                          ),
                          SwitchListTile(
                            title: Text(l10n.pageTurnSettingsSheetSwipeUpNext),
                            value: current.swipeUp,
                            onChanged: (v) =>
                                update(current.copyWith(swipeUp: v)),
                          ),
                          SwitchListTile(
                            title: Text(
                              l10n.pageTurnSettingsSheetSwipeDownPrevious,
                            ),
                            value: current.swipeDown,
                            onChanged: (v) =>
                                update(current.copyWith(swipeDown: v)),
                          ),
                        ],
                        const Divider(height: 32),
                        SwitchListTile(
                          title: Text(
                            l10n.pageTurnSettingsSheetReverseDirection,
                          ),
                          subtitle: Text(
                            l10n.pageTurnSettingsSheetReverseDirectionSubtitle,
                          ),
                          value: current.reverseDirection,
                          onChanged: (v) =>
                              update(current.copyWith(reverseDirection: v)),
                        ),
                        // Hidden where it does nothing: One page always
                        // advances one page, and Half Page always advances
                        // half a viewport internally without exposing the
                        // choice (Spec 0056).
                        if (turnAmountApplies(layoutMode)) ...[
                          const Divider(height: 32),
                          Text(
                            l10n.pageTurnSettingsSheetTurnAmount,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            layoutMode == PdfLayoutMode.twoPage
                                ? l10n
                                      .pageTurnSettingsSheetTurnAmountHintTwoPage
                                : l10n
                                      .pageTurnSettingsSheetTurnAmountHintDefault,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: TurnAmount.values.map((amount) {
                              return ChoiceChip(
                                label: Text(_turnAmountLabel(l10n, amount)),
                                selected: current.turnAmount == amount,
                                onSelected: (_) => update(
                                  current.copyWith(turnAmount: amount),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const Divider(height: 32),
                        Text(
                          l10n.pageTurnSettingsSheetAnimation,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PageTurnAnimationPreset.values.map((
                            preset,
                          ) {
                            return ChoiceChip(
                              label: Text(_animationLabel(l10n, preset)),
                              selected: current.animationPreset == preset,
                              onSelected: (_) => update(
                                current.copyWith(animationPreset: preset),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        Text(
                          l10n.pageTurnSettingsSheetPageTurnDelay,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PageTurnDelayPreset.values.map((preset) {
                            return ChoiceChip(
                              label: Text(_delayLabel(l10n, preset)),
                              selected: current.delayPreset == preset,
                              onSelected: (_) =>
                                  update(current.copyWith(delayPreset: preset)),
                            );
                          }).toList(),
                        ),
                        if (current.delayPreset != PageTurnDelayPreset.off) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.pageTurnSettingsSheetApplyTo,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: PageTurnDelayScope.values.map((scope) {
                              return ChoiceChip(
                                label: Text(_scopeLabel(l10n, scope)),
                                selected: current.delayScope == scope,
                                onSelected: (_) =>
                                    update(current.copyWith(delayScope: scope)),
                              );
                            }).toList(),
                          ),
                        ],
                        const Divider(height: 32),
                        Text(
                          l10n.pageTurnSettingsSheetGestures,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.pageTurnSettingsSheetGesturesHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _GestureRow(
                          label: l10n.pageTurnSettingsSheetLongPress,
                          l10n: l10n,
                          value: current.gestureMap.longPress,
                          onChanged: (a) => updateGesture(
                            current.gestureMap.copyWith(longPress: a),
                          ),
                        ),
                        _GestureRow(
                          label: l10n.pageTurnSettingsSheetTopEdge,
                          l10n: l10n,
                          value: current.gestureMap.topEdge,
                          onChanged: (a) => updateGesture(
                            current.gestureMap.copyWith(topEdge: a),
                          ),
                        ),
                        _GestureRow(
                          label: l10n.pageTurnSettingsSheetBottomEdge,
                          l10n: l10n,
                          value: current.gestureMap.bottomEdge,
                          onChanged: (a) => updateGesture(
                            current.gestureMap.copyWith(bottomEdge: a),
                          ),
                        ),
                        const Divider(height: 32),
                        Text(
                          l10n.pageTurnSettingsSheetPedalKeyboard,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.pageTurnSettingsSheetPedalKeyboardHint,
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
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final AppLocalizations l10n;
  final GestureMapAction value;
  final ValueChanged<GestureMapAction> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GestureMapAction.values.map((action) {
              return ChoiceChip(
                label: Text(_gestureActionLabel(l10n, action)),
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

String _animationLabel(AppLocalizations l10n, PageTurnAnimationPreset preset) {
  return switch (preset) {
    PageTurnAnimationPreset.off => l10n.pageTurnAnimationOff,
    PageTurnAnimationPreset.fast => l10n.pageTurnAnimationFast,
    PageTurnAnimationPreset.normal => l10n.pageTurnAnimationNormal,
    PageTurnAnimationPreset.slow => l10n.pageTurnAnimationSlow,
  };
}

String _delayLabel(AppLocalizations l10n, PageTurnDelayPreset preset) {
  return switch (preset) {
    PageTurnDelayPreset.off => l10n.pageTurnDelayOff,
    PageTurnDelayPreset.ms300 => l10n.pageTurnDelay300ms,
    PageTurnDelayPreset.ms500 => l10n.pageTurnDelay500ms,
    PageTurnDelayPreset.ms1000 => l10n.pageTurnDelay1000ms,
  };
}

String _scopeLabel(AppLocalizations l10n, PageTurnDelayScope scope) {
  return switch (scope) {
    PageTurnDelayScope.all => l10n.pageTurnDelayScopeAll,
    PageTurnDelayScope.pedalOnly => l10n.pageTurnDelayScopePedalOnly,
  };
}

String _tapModeLabel(AppLocalizations l10n, PageTurnTapMode mode) {
  return switch (mode) {
    PageTurnTapMode.matchLayout => l10n.pageTurnTapModeMatchLayout,
    PageTurnTapMode.leftRight => l10n.pageTurnTapModeLeftRight,
    PageTurnTapMode.topBottom => l10n.pageTurnTapModeTopBottom,
    PageTurnTapMode.previous => l10n.pageTurnTapModePrevious,
    PageTurnTapMode.next => l10n.pageTurnTapModeNext,
    PageTurnTapMode.disabled => l10n.pageTurnTapModeDisabled,
  };
}

String _turnAmountLabel(AppLocalizations l10n, TurnAmount amount) {
  return switch (amount) {
    TurnAmount.full => l10n.turnAmountFull,
    TurnAmount.half => l10n.turnAmountHalf,
  };
}

String _gestureActionLabel(AppLocalizations l10n, GestureMapAction action) {
  return switch (action) {
    GestureMapAction.showChrome => l10n.gestureMapActionShowChrome,
    GestureMapAction.disabled => l10n.gestureMapActionDisabled,
  };
}
