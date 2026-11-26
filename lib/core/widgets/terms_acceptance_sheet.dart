import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:competition_career_academy/core/theme/app_colors.dart';
import 'package:competition_career_academy/core/theme/app_typography.dart';
import 'package:competition_career_academy/core/theme/screen.dart';

/// Course / bundle Terms & Conditions, shown after Buy Now and before the
/// order summary.
///
/// The terms open as a short, faded preview with "Read more". Expanding
/// shows the full text, and the "I have read and agree" checkbox sits at
/// the end of it. The checkbox stays disabled until the full terms have
/// been opened (or straight away, when the text is short enough to need
/// no "Read more"), and "Agree & Proceed" stays disabled until it's ticked.
///
/// The server only sends terms when the org has the feature on, the
/// educator switched terms on for this course/bundle and the text is not
/// blank — so callers simply show this whenever `terms` is non-empty.
///
/// Resolves `true` only on Agree & Proceed; back, swipe-down or Cancel
/// give `false`.
class TermsAcceptanceSheet extends StatefulWidget {
  final String terms;
  final String title;

  const TermsAcceptanceSheet({
    super.key,
    required this.terms,
    this.title = 'Terms & Conditions',
  });

  static Future<bool> show(
    BuildContext context, {
    required String terms,
    String title = 'Terms & Conditions',
  }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TermsAcceptanceSheet(terms: terms, title: title),
    );
    return ok == true;
  }

  @override
  State<TermsAcceptanceSheet> createState() => _TermsAcceptanceSheetState();
}

class _TermsAcceptanceSheetState extends State<TermsAcceptanceSheet> {
  /// Height of the collapsed preview — roughly five lines of terms.
  static const double _previewHeight = 150;

  final GlobalKey _termsKey = GlobalKey();

  /// Null until measured after the first frame.
  bool? _needsReadMore;
  bool _expanded = false;
  bool _agreed = false;

  /// The checkbox unlocks once the learner has the whole text in front of
  /// them: expanded, or short enough that the preview already shows it all.
  bool get _canAgree => _expanded || _needsReadMore == false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final box = _termsKey.currentContext?.findRenderObject() as RenderBox?;
    final height = box?.hasSize == true ? box!.size.height : 0.0;
    setState(() => _needsReadMore = height > _previewHeight + 8);
  }

  void _toggleAgreed() {
    if (!_canAgree) return;
    setState(() => _agreed = !_agreed);
  }

  MarkdownStyleSheet _styleSheet(BuildContext context) {
    final body = AppTypography.bodyTextLargeMedium.copyWith(
      fontSize: Screen.getFontSize(15),
      color: AppColors.textPrimary,
      height: 1.6,
    );
    final heading = AppTypography.bodyTextLargeBold.copyWith(
      fontSize: Screen.getFontSize(16),
      color: AppColors.textPrimary,
      height: 1.4,
    );
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: body,
      listBullet: body.copyWith(color: AppColors.mutedTextPrimary),
      strong: body.copyWith(fontWeight: FontWeight.w700),
      em: body.copyWith(fontStyle: FontStyle.italic),
      a: body.copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      ),
      h1: heading.copyWith(fontSize: Screen.getFontSize(18)),
      h2: heading.copyWith(fontSize: Screen.getFontSize(17)),
      h3: heading,
      h4: heading,
      h5: heading,
      h6: heading,
      pPadding: const EdgeInsets.only(bottom: 2),
      h1Padding: const EdgeInsets.only(bottom: 8),
      h2Padding: const EdgeInsets.only(bottom: 8),
      h3Padding: const EdgeInsets.only(bottom: 8),
      blockSpacing: 10,
      listIndent: 22,
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTermsCard(context),
                  const SizedBox(height: 14),
                  _buildAgreeTile(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.h5Bold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Please review before you continue',
                      style: AppTypography.bodyTextMedium.copyWith(
                        color: AppColors.mutedTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard(BuildContext context) {
    final terms = KeyedSubtree(
      key: _termsKey,
      child: MarkdownBody(data: widget.terms, styleSheet: _styleSheet(context)),
    );
    final collapsed = _needsReadMore != false && !_expanded;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: collapsed
                // The text is laid out at full height and clipped, so it
                // can be measured; the fade hints that more follows.
                ? SizedBox(
                    height: _previewHeight,
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0, 0.6, 1],
                      ).createShader(rect),
                      blendMode: BlendMode.dstIn,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: terms,
                      ),
                    ),
                  )
                : terms,
          ),
          if (_needsReadMore == true)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  textStyle: AppTypography.bodyTextSemiBold,
                ),
                iconAlignment: IconAlignment.end,
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                ),
                label: Text(_expanded ? 'Show less' : 'Read more'),
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAgreeTile() {
    final enabled = _canAgree;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: _agreed
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: _agreed ? AppColors.primary : AppColors.dividerLight,
            width: _agreed ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? _toggleAgreed : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
            child: Row(
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: enabled ? (_) => _toggleAgreed() : null,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I have read and agree to the Terms & Conditions',
                        style: AppTypography.bodyTextLargeSemiBold.copyWith(
                          fontSize: Screen.getFontSize(15),
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                      if (!enabled) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap "Read more" to view the full terms',
                          style: AppTypography.bodyTextSmallMedium.copyWith(
                            color: AppColors.mutedTextPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.dividerLight)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.dividerLight),
                textStyle: AppTypography.buttonLarge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: _agreed ? () => Navigator.of(context).pop(true) : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
                textStyle: AppTypography.buttonLarge,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Agree & Proceed'),
            ),
          ),
        ],
      ),
    );
  }
}
