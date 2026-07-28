/// Everything a musician reads about who makes StageScore, defined once.
///
/// One place on purpose. The StandScore → StageScore rename shipped the old
/// name to the Android launcher because the name lived in as many files as
/// used it; brand strings get the same single-definition treatment as
/// `libraryRootDirName` for exactly that reason.
///
/// Spelling follows ADR 0010: a person reads **Backing & Score**, while
/// identifiers — the domain, `com.backingscore.scoreapp`, the Android package —
/// keep the compressed form and are not defined here.
library;

class Brand {
  const Brand._();

  /// The app-facing name (ADR 0009). The publisher never replaces it.
  static const productName = 'StageScore';

  static const publisher = 'Backing & Score';

  static const siteUrl = 'https://backingscore.com';

  /// Default locale is unprefixed on the site, so this resolves without `/en`.
  static const privacyUrl = 'https://backingscore.com/privacy';

  /// There is no support *page*; the published contact is an address.
  static const supportEmail = 'support@backingscore.com';

  /// The one quiet line the Library empty state carries (Spec 0042).
  static const publisherLine = 'A $publisher app';

  static const aboutHeadline = 'Part of $publisher';

  /// What the rest of the ecosystem does, without promising any of it here:
  /// StageScore is offline and does none of this itself.
  static const aboutBlurb =
      'Interactive sheet music, play-along backing tracks and live '
      'classes, on the web at backingscore.com.';

  static Uri get supportUri => Uri(
    scheme: 'mailto',
    path: supportEmail,
    queryParameters: const {'subject': '$productName support'},
  );
}
