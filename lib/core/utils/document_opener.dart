import 'dart:async';

import 'package:competition_career_academy/core/router/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// How a document URL should be rendered.
enum DocumentKind {
  /// Rendered natively by the in-app PDF viewer.
  pdf,

  /// Word / Excel / PowerPoint. WebViews can't render these (Android just
  /// triggers a download that goes nowhere → blank screen), so they go
  /// through Microsoft's Office Online viewer.
  office,

  /// PNG / JPG etc. — the PDF viewer route handles these too.
  image,

  /// Anything else (HTML pages, Google Docs links, …) — plain WebView.
  web,
}

/// Single place that decides how to open a document URL, shared by the
/// course Content tab and the assignment page.
///
/// Detection order:
/// 1. Extension in the URL path (`/files/notes.docx`).
/// 2. Extension anywhere in the query string (`?file=notes.docx`,
///    `response-content-disposition=…notes.docx`).
/// 3. Extension in the node / file name shown to the user.
/// 4. A 1-byte ranged GET to read `Content-Type` / `Content-Disposition`
///    when the URL has no extension (proxy / signed links).
class DocumentOpener {
  DocumentOpener._();

  static const _officeExt = {
    'doc', 'docx', 'docm', 'dot', 'dotx', 'rtf', 'odt', //
    'xls', 'xlsx', 'xlsm', 'csv', 'ods',
    'ppt', 'pptx', 'pps', 'ppsx', 'odp',
  };
  static const _imageExt = {'png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'};

  static final _extRe = RegExp(r'\.([a-z0-9]{2,5})(?=$|[^a-z0-9])');

  /// Microsoft's free viewer. The source URL must be publicly reachable
  /// (no auth header, not localhost, not about to expire).
  ///
  /// Must be `embed.aspx`, not `view.aspx`: on Android, `view.aspx`
  /// redirects to a mobile Word frame that renders a blank white page
  /// (even in full Chrome — verified Nov 2026). `embed.aspx` renders the
  /// document inline on mobile.
  static String officeViewerUrl(String url) =>
      'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(url)}';

  /// Synchronous best-effort detection; null when nothing conclusive.
  static DocumentKind? detect(String url, {String? name}) {
    final uri = Uri.tryParse(url);
    final candidates = <String>[
      (uri?.path ?? url),
      if (uri != null) Uri.decodeComponent(uri.query),
      ?name,
    ];
    for (final c in candidates) {
      final kind = _kindFromText(c.toLowerCase());
      if (kind != null) return kind;
    }
    return null;
  }

  static DocumentKind? _kindFromText(String text) {
    // Last extension wins (`report.v2.docx`).
    final matches = _extRe.allMatches(text).toList();
    for (final m in matches.reversed) {
      final ext = m.group(1)!;
      if (ext == 'pdf') return DocumentKind.pdf;
      if (_officeExt.contains(ext)) return DocumentKind.office;
      if (_imageExt.contains(ext)) return DocumentKind.image;
    }
    return null;
  }

  static DocumentKind? _kindFromMime(String? mime) {
    if (mime == null) return null;
    final m = mime.toLowerCase();
    if (m.contains('pdf')) return DocumentKind.pdf;
    if (m.contains('msword') ||
        m.contains('wordprocessingml') ||
        m.contains('ms-excel') ||
        m.contains('spreadsheetml') ||
        m.contains('ms-powerpoint') ||
        m.contains('presentationml') ||
        m.contains('opendocument') ||
        m.contains('rtf')) {
      return DocumentKind.office;
    }
    if (m.startsWith('image/')) return DocumentKind.image;
    if (m.startsWith('text/html')) return DocumentKind.web;
    return null;
  }

  /// Full detection including a network probe for extension-less URLs.
  static Future<DocumentKind> resolve(String url, {String? name}) async {
    final quick = detect(url, name: name);
    if (quick != null) return quick;
    if (!url.toLowerCase().startsWith('http')) return DocumentKind.web;
    return await _probe(url) ?? DocumentKind.web;
  }

  /// Ranged GET (not HEAD — S3 links signed for GET reject HEAD) that
  /// only reads the response headers, then cancels the body.
  static Future<DocumentKind?> _probe(String url) async {
    final cancel = CancelToken();
    try {
      final resp = await Dio()
          .get<ResponseBody>(
            url,
            cancelToken: cancel,
            options: Options(
              headers: {'Range': 'bytes=0-0'},
              responseType: ResponseType.stream,
              followRedirects: true,
              validateStatus: (_) => true,
            ),
          )
          .timeout(const Duration(seconds: 6));
      final disposition = resp.headers.value('content-disposition');
      final type = resp.headers.value(Headers.contentTypeHeader);
      cancel.cancel();
      return (disposition != null
              ? _kindFromText(disposition.toLowerCase())
              : null) ??
          _kindFromMime(type);
    } catch (_) {
      if (!cancel.isCancelled) cancel.cancel();
      return null;
    }
  }

  /// Opens [url] in the right viewer.
  ///
  /// * [pdfQuery] is appended to the PDF viewer route (completion args).
  /// * [pdfExtra] is passed as `extra` to the PDF viewer route.
  /// * [onNonPdfOpened] fires when anything other than the PDF viewer
  ///   opens (those viewers don't track progress themselves).
  static Future<void> open(
    BuildContext context, {
    required String url,
    required String title,
    String? name,
    String pdfQuery = '',
    Object? pdfExtra,
    VoidCallback? onNonPdfOpened,
  }) async {
    final kind = await resolve(url, name: name ?? title);
    if (!context.mounted) return;

    final encTitle = Uri.encodeComponent(title);
    switch (kind) {
      case DocumentKind.pdf:
      case DocumentKind.image:
        context.push(
          '${AppRoutes.pdfViewer}?title=$encTitle'
          '&url=${Uri.encodeComponent(url)}$pdfQuery',
          extra: pdfExtra,
        );
        if (kind == DocumentKind.image) onNonPdfOpened?.call();
      case DocumentKind.office:
        onNonPdfOpened?.call();
        context.push(
          '${AppRoutes.documentViewer}?title=$encTitle'
          '&url=${Uri.encodeComponent(officeViewerUrl(url))}'
          '&externalUrl=${Uri.encodeComponent(url)}',
        );
      case DocumentKind.web:
        onNonPdfOpened?.call();
        if (url.toLowerCase().startsWith('http')) {
          context.push(
            '${AppRoutes.documentViewer}?title=$encTitle'
            '&url=${Uri.encodeComponent(url)}'
            '&externalUrl=${Uri.encodeComponent(url)}',
          );
        } else {
          await openExternally(url);
        }
    }
  }

  /// Hands the file to another app (Word, Docs, browser…).
  static Future<bool> openExternally(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
