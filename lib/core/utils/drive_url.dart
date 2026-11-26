/// Google Drive link helpers.
///
/// Educators paste Drive *share* links (`drive.google.com/file/d/<id>/view`)
/// for image content. Those open Drive's HTML preview page, not the image
/// itself, so an image widget can't decode them ("Could not load image").
/// [driveDirectImageUrl] rewrites such links to Google's image host, which
/// serves the raw bytes for any file shared as "Anyone with the link".
library;

final RegExp _filePathId = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');

/// The Drive file id in [url], or null when [url] isn't a Drive file link.
///
/// Handles `/file/d/<id>/…`, `open?id=<id>`, `uc?id=<id>` and
/// `thumbnail?id=<id>`.
String? driveFileId(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  final host = uri.host.toLowerCase();
  if (host != 'drive.google.com' && host != 'docs.google.com') return null;

  final fromPath = _filePathId.firstMatch(uri.path)?.group(1);
  if (fromPath != null) return fromPath;

  final fromQuery = uri.queryParameters['id'];
  return (fromQuery != null && fromQuery.isNotEmpty) ? fromQuery : null;
}

/// [url] as a directly loadable image when it is a Drive file link;
/// any other URL is returned unchanged.
String driveDirectImageUrl(String url) {
  final id = driveFileId(url);
  return id == null ? url : 'https://lh3.googleusercontent.com/d/$id';
}

/// Drive's own embedded player page for the file in [url]
/// (`drive.google.com/file/d/<id>/preview`), or null when [url] isn't a
/// Drive file link.
///
/// Drive serves the file itself in this player — a video of any size, or a
/// PDF — so showing Free Content needs nothing on our servers.
/// Unlike a `uc?export=download` link it doesn't break on files over
/// ~100 MB (Drive's virus-scan interstitial) and seeks properly.
String? driveEmbedUrl(String url) {
  final id = driveFileId(url);
  return id == null ? null : 'https://drive.google.com/file/d/$id/preview';
}
