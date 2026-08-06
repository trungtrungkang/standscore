/// What splitting a book, or moving a piece's PageExtent, owes the overlays
/// that were keyed to the whole file (Spec 0052).
///
/// Deliberately not methods on `ScoreLibrary`. Per-page scale lives in an
/// app-level prefs file and PageOrder in a per-Score file; neither is the
/// manifest's business, and pulling them in would make the one writer that
/// must stay atomic depend on every store in the app.
library;

import 'dart:io';

import 'package:stagescore/layout/page_scale_prefs_store.dart';
import 'package:stagescore/library/page_extent.dart';
import 'package:stagescore/library/score.dart';
import 'package:stagescore/pageorder/page_order_store.dart';

/// Hand per-page scale overrides from [originalScoreId] to whoever owns each
/// page now (Spec 0052 / 0055).
///
/// After a first split the original id is the whole-file root (`pageExtent`
/// null), so overrides must move onto the children that cover those pages.
/// Resplitting a child moves overrides from that child onto its siblings the
/// same way. Only Scores with a PageExtent are owners — a null-extent root
/// never claims a page here.
Future<void> handOverPageScales({
  required Directory root,
  required String originalScoreId,
  required List<Score> pieces,
}) async {
  final store = PageScalePrefsStore(root: root);
  final prefs = await store.load();
  final next = prefs.reassignPageScales(
    scoreId: originalScoreId,
    ownerOf: (sourcePage) => _ownerOf(pieces, sourcePage),
  );
  if (next == prefs) return;
  await store.save(next);
}

String? _ownerOf(List<Score> pieces, int sourcePage) {
  for (final piece in pieces) {
    if (piece.pageExtent?.contains(sourcePage) ?? false) return piece.id;
  }
  return null;
}

/// How many PageOrder slots of [scoreId] fall outside [extent].
///
/// Asked *before* the musician confirms a narrower extent: unlike annotations,
/// which are simply hidden and come back, a performance sequence has to stay
/// consistent, so slots pointing outside the piece are dropped — and being
/// told a number afterwards is being told too late (Spec 0052, G3 #5).
Future<int> pageOrderSlotsOutside({
  required Directory root,
  required String scoreId,
  required PageExtent extent,
}) async {
  final stored = await PageOrderStore(root: root, scoreId: scoreId).loadStored();
  if (stored == null) return 0;
  return stored.slotsOutside(
    firstPage: extent.firstPage,
    lastPage: extent.lastPage,
  );
}

/// Rebase [scoreId]'s stored PageOrder on [extent]; answers how many slots
/// were dropped.
///
/// Does nothing when the Score has no stored order — a piece that never had one
/// gets its plain page order from its extent on the next open.
Future<int> restrictPageOrderTo({
  required Directory root,
  required String scoreId,
  required PageExtent extent,
}) async {
  final store = PageOrderStore(root: root, scoreId: scoreId);
  final stored = await store.loadStored();
  if (stored == null) return 0;
  final restricted = stored.restrictedTo(
    firstPage: extent.firstPage,
    lastPage: extent.lastPage,
  );
  if (restricted == stored) return 0;
  final dropped = stored.slotsOutside(
    firstPage: extent.firstPage,
    lastPage: extent.lastPage,
  );
  await store.save(restricted);
  return dropped;
}
