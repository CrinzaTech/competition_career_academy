import 'package:competition_career_academy/core/theme/app_colors.dart';
import 'package:competition_career_academy/core/theme/screen.dart';
import 'package:competition_career_academy/core/utils/document_opener.dart';
import 'package:competition_career_academy/core/widgets/custom_appbar_widget.dart';
import 'package:competition_career_academy/core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocumentViewerPage extends StatefulWidget {
  final String title;

  /// What the WebView loads (for Office files: the Office Online
  /// viewer URL wrapping the real file).
  final String url;

  /// The raw file URL, handed to another app via "Open in another app".
  /// Falls back to [url] when not given.
  final String? externalUrl;

  const DocumentViewerPage({
    super.key,
    required this.title,
    required this.url,
    this.externalUrl,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  String get _externalUrl => widget.externalUrl ?? widget.url;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.grey100)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // Sub-resource failures (ads, fonts, telemetry) are noise —
            // only a main-frame failure means the document didn't load.
            if (error.isForMainFrame == false) return;
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = 'The document could not be loaded.';
              });
            }
          },
          onHttpError: (error) {
            final code = error.response?.statusCode ?? 0;
            final isMain =
                error.request == null ||
                error.request!.uri.toString() == widget.url;
            if (code >= 400 && isMain && mounted) {
              setState(() {
                _isLoading = false;
                _error = 'The document could not be loaded (error $code).';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openExternally() async {
    final ok = await DocumentOpener.openExternally(_externalUrl);
    if (!ok && mounted) {
      CustomSnackbar.error(
        context,
        title: 'Unable to open',
        message: 'No app on this device can open this file.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Screen().adaptDeviceScreenSize(context);

    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: CustomAppBar(
        title: widget.title,
        centerTitle: true,
        titleColor: AppColors.white,
        backgroundColor: AppColors.videoPlayerBgColor,
        actions: [
          IconButton(
            tooltip: 'Open in another app',
            icon: Icon(Icons.open_in_new, color: AppColors.white),
            onPressed: _openExternally,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_error == null) WebViewWidget(controller: _controller),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 56,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _openExternally,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open in another app'),
                    ),
                    TextButton(onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          if (_isLoading && _error == null)
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}
