import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stagescore/brand/brand.dart';
import 'package:stagescore/theme/app_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Where the musician learns who makes StageScore, and which build they have
/// when something goes wrong (Spec 0042).
///
/// A sheet rather than a route, matching the 0035 idiom: everything else
/// reached from a ⋯ entry opens this way, and a pushed screen for a static
/// panel would be the odd one out.
///
/// Both seams are injectable because both are platform channels: the version
/// comes from the bundle rather than a literal, and a link hands off to the
/// system browser. Tests supply their own and never touch either channel.
Future<void> showAboutSheet({
  required BuildContext context,
  Future<AppBuild> Function()? readBuild,
  Future<bool> Function(Uri url)? launch,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AboutSheet(
      readBuild: readBuild ?? AppBuild.fromPlatform,
      launch: launch ?? _launchExternal,
    ),
  );
}

Future<bool> _launchExternal(Uri url) {
  return launchUrl(url, mode: LaunchMode.externalApplication);
}

/// The app's own version, read from the bundle it was built into.
///
/// Not a constant in Dart: a second copy of `pubspec.yaml`'s version drifts on
/// the first hotfix, and the number is only useful in a support thread if it
/// is the one the store actually shipped.
class AppBuild {
  const AppBuild({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  static Future<AppBuild> fromPlatform() async {
    final info = await PackageInfo.fromPlatform();
    return AppBuild(version: info.version, buildNumber: info.buildNumber);
  }

  /// "Version 1.0.0 (4)", or without the parenthesis on a host that has no
  /// build number to report.
  String get label => buildNumber.isEmpty
      ? 'Version $version'
      : 'Version $version ($buildNumber)';
}

class _AboutSheet extends StatefulWidget {
  const _AboutSheet({required this.readBuild, required this.launch});

  final Future<AppBuild> Function() readBuild;
  final Future<bool> Function(Uri url) launch;

  @override
  State<_AboutSheet> createState() => _AboutSheetState();
}

class _AboutSheetState extends State<_AboutSheet> {
  AppBuild? _build;

  @override
  void initState() {
    super.initState();
    _loadBuild();
  }

  Future<void> _loadBuild() async {
    try {
      final build = await widget.readBuild();
      if (!mounted) return;
      setState(() => _build = build);
    } catch (_) {
      // No platform channel on this host: the rest of the sheet still reads.
    }
  }

  /// A tap that cannot reach a browser says so instead of doing nothing —
  /// there is no other feedback on a link row, and the sheet must survive a
  /// device with no browser or no network (Spec 0042).
  Future<void> _open(Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await widget.launch(url);
    } catch (_) {
      opened = false;
    }
    if (opened || !mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
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
                        'About ${Brand.productName}',
                        style: theme.textTheme.titleLarge,
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
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.asset(
                            'assets/brand/stagescore-logo.png',
                            height: 56,
                            width: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Brand.productName,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _build?.label ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Brand.aboutHeadline,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          Brand.aboutBlurb,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _LinkRow(
                    icon: Icons.language,
                    label: 'backingscore.com',
                    onTap: () => _open(Uri.parse(Brand.siteUrl)),
                  ),
                  _LinkRow(
                    icon: Icons.lock_outline,
                    label: 'Privacy policy',
                    onTap: () => _open(Uri.parse(Brand.privacyUrl)),
                  ),
                  _LinkRow(
                    icon: Icons.mail_outline,
                    label: 'Support',
                    trailingLabel: Brand.supportEmail,
                    onTap: () => _open(Brand.supportUri),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingLabel,
  });

  final IconData icon;
  final String label;
  final String? trailingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: trailingLabel == null
          ? null
          : Text(
              trailingLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: onTap,
    );
  }
}
