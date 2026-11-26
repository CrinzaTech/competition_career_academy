import 'package:competition_career_academy/core/config/di/dependency_injection.dart';
import 'package:competition_career_academy/core/services/content_completion_service.dart';
import 'package:competition_career_academy/core/theme/app_colors.dart';
import 'package:competition_career_academy/core/theme/screen.dart';
import 'package:competition_career_academy/core/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Shows a Free Content Google Drive video or PDF in Drive's own
/// `/preview` player, inside a WebView. The file streams straight from
/// Drive; nothing passes through or is stored on our servers.
///
/// Drive's player exposes no playback progress, so completion is recorded
/// on open (the same rule as image nodes) when tracking ids are supplied.
class DriveEmbedPage extends StatefulWidget {
  final String title;

  /// The resolved `drive.google.com/file/d/<id>/preview` URL (see
  /// `driveEmbedUrl`), not the educator's raw share link.
  final String url;
  final int coursePurchasedId;
  final String nodeId;

  const DriveEmbedPage({
    super.key,
    required this.title,
    required this.url,
    this.coursePurchasedId = 0,
    this.nodeId = '',
  });

  @override
  State<DriveEmbedPage> createState() => _DriveEmbedPageState();
}

class _DriveEmbedPageState extends State<DriveEmbedPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.coursePurchasedId != 0 && widget.nodeId.isNotEmpty) {
      sl<ContentCompletionService>().markCompleted(
        coursePurchasedId: widget.coursePurchasedId,
        jsonContentId: widget.nodeId,
      );
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.videoPlayerBgColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (mounted) setState(() => _isLoading = false);
          },
          // Stay on the player: Drive's pop-out and account links would
          // otherwise navigate the WebView to a Drive page with no way
          // back. Hand them to the system browser / Drive app instead.
          onNavigationRequest: (request) {
            // Redirects while the player first loads are the player's own.
            if (_isLoading) return NavigationDecision.navigate;
            final uri = Uri.tryParse(request.url);
            if (request.isMainFrame && uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    Screen().adaptDeviceScreenSize(context);
    return Scaffold(
      backgroundColor: AppColors.videoPlayerBgColor,
      appBar: CustomAppBar(
        title: widget.title,
        centerTitle: true,
        titleColor: AppColors.white,
        backgroundColor: AppColors.videoPlayerBgColor,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
