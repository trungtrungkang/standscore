/// Parse a user-entered page number. Returns null if empty or not an integer.
int? parsePageNumber(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}

/// Clamp [page] into `1…pageCount`. If [pageCount] < 1, returns 1.
int clampPageNumber(int page, int pageCount) {
  if (pageCount < 1) return 1;
  return page.clamp(1, pageCount);
}
