import 'dart:async';
import 'dart:math' as math;

import 'package:competition_career_academy/core/theme/app_colors.dart';
import 'package:competition_career_academy/core/theme/app_typography.dart';
import 'package:competition_career_academy/core/theme/screen.dart';
import 'package:competition_career_academy/core/widgets/inner_shadow_painter.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SwipeToPayButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  final String text;

  const SwipeToPayButton({
    super.key,
    required this.onSwipeComplete,
    this.text = 'Proceed to Pay Securely',
  });

  @override
  State<SwipeToPayButton> createState() => _SwipeToPayButtonState();
}

class _SwipeToPayButtonState extends State<SwipeToPayButton>
    with TickerProviderStateMixin {
  /// Wait before the first "how to swipe" demo, and between repeats.
  static const Duration _hintFirstDelay = Duration(milliseconds: 1500);
  static const Duration _hintRepeatDelay = Duration(milliseconds: 2500);

  /// How far along the track the demo drags the thumb (0–1).
  static const double _hintReach = 0.55;

  bool _isCompleted = false;
  late AnimationController _animationController;

  /// Drives one demo cycle: a hand presses the thumb, drags it right,
  /// lifts, and the thumb slides back. Many learners don't realise the
  /// button must be dragged, so it replays until they first touch it.
  late AnimationController _hintController;
  Timer? _hintTimer;
  bool _hintStopped = false;

  @override
  void initState() {
    super.initState();
    // 0.0 to 1.0 representing percentage of completion
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Respect the system "remove animations" accessibility setting.
      if (MediaQuery.of(context).disableAnimations) {
        _hintStopped = true;
        return;
      }
      _scheduleHint(_hintFirstDelay);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _hintController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scheduleHint(Duration delay) {
    _hintTimer?.cancel();
    _hintTimer = Timer(delay, _playHint);
  }

  void _playHint() {
    if (!mounted || _hintStopped || _isCompleted) return;
    _hintController.forward(from: 0).whenCompleteOrCancel(() {
      if (mounted && !_hintStopped && !_isCompleted) {
        _scheduleHint(_hintRepeatDelay);
      }
    });
  }

  /// The learner touched the button — they've found it, so the demo
  /// stops for good and the thumb is theirs.
  void _stopHint() {
    if (_hintStopped) return;
    _hintStopped = true;
    _hintTimer?.cancel();
    _hintController.stop();
    _hintController.value = 0;
  }

  // ── Demo timeline (t = 0…1 over one cycle) ─────────────────────────────
  //  0.00–0.15  hand fades in and presses the thumb
  //  0.15–0.60  hand + thumb drag right to _hintReach
  //  0.60–0.72  hold at the end; hand lifts and fades
  //  0.72–1.00  thumb slides back to the start

  double get _hintThumb {
    final t = _hintController.value;
    if (t < 0.15) return 0;
    if (t < 0.60) {
      return Curves.easeInOut.transform((t - 0.15) / 0.45) * _hintReach;
    }
    if (t < 0.72) return _hintReach;
    return (1 - Curves.easeInOut.transform((t - 0.72) / 0.28)) * _hintReach;
  }

  double get _hintHandOpacity {
    final t = _hintController.value;
    if (t <= 0) return 0;
    if (t < 0.10) return t / 0.10;
    if (t < 0.62) return 1;
    if (t < 0.72) return 1 - (t - 0.62) / 0.10;
    return 0;
  }

  /// Slightly larger while hovering in, settling to 1.0 as it "presses".
  double get _hintHandScale {
    final t = _hintController.value;
    if (t < 0.15) return 1.18 - 0.18 * Curves.easeOut.transform(t / 0.15);
    if (t > 0.60 && t < 0.72) {
      return 1 + 0.12 * ((t - 0.60) / 0.12); // lifting off
    }
    return 1;
  }

  /// Where the thumb is drawn: the learner's drag, or the demo while it runs.
  double get _position => _hintStopped
      ? _animationController.value
      : math.max(_animationController.value, _hintThumb);

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (_isCompleted || maxDrag == 0) return;
    _animationController.value += details.delta.dx / maxDrag;
  }

  void _onDragEnd(DragEndDetails details, double maxDrag) {
    if (_isCompleted) return;

    if (_animationController.value > 0.75) {
      // Completed
      _animationController.forward().then((_) {
        setState(() {
          _isCompleted = true;
        });
        widget.onSwipeComplete();
      });
    } else {
      // Snap back
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = Screen.getVerticalSize(54);
    final handSize = Screen.getSize(38);
    final animation = Listenable.merge([_animationController, _hintController]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = (constraints.maxWidth - thumbSize - 8.0).clamp(
          0.0,
          double.infinity,
        );

        // Any touch on the button ends the demo — even one that misses
        // the thumb means the learner has found it.
        return Listener(
          onPointerDown: (_) => _stopHint(),
          child: Container(
            height: thumbSize + 8,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.mutedTextPrimary.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              // The demo hand hangs below the thumb, past the track's edge.
              clipBehavior: Clip.none,
              children: [
                // Inner shadow for recessed look
                Positioned.fill(
                  child: CustomPaint(
                    painter: InnerShadowPainter(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                // Background text
                Center(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: (1 - _position).clamp(0.0, 1.0),
                        child: child!,
                      );
                    },
                    child: Shimmer.fromColors(
                      baseColor: AppColors.primary,
                      highlightColor: AppColors.primary.withValues(alpha: 0.3),
                      child: Text(
                        widget.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyTextLargeSemiBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Filled track behind thumb
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final dragPos = _position * maxDrag;
                    if (dragPos <= 0) return const SizedBox.shrink();
                    return Positioned(
                      left: 4,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        width: dragPos + (thumbSize / 2),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            AppColors.primary.withValues(alpha: 0.4),
                            AppColors.success.withValues(alpha: 0.5),
                            _position,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(100),
                            bottomLeft: Radius.circular(100),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Thumb
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final dragPos = _position * maxDrag;
                    return Positioned(
                      left: dragPos + 4,
                      child: GestureDetector(
                        onHorizontalDragStart: (_) => _stopHint(),
                        onHorizontalDragUpdate: (details) =>
                            _onDragUpdate(details, maxDrag),
                        onHorizontalDragEnd: (details) =>
                            _onDragEnd(details, maxDrag),
                        child: Container(
                          width: thumbSize,
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFill,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child:
                                _isCompleted ||
                                    _animationController.value == 1.0
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppColors.onPrimary,
                                  )
                                : Icon(
                                    Icons.keyboard_double_arrow_right_rounded,
                                    color: AppColors.onPrimary,
                                    size: Screen.getSize(24),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Demo hand: fingertip on the thumb's centre, riding along
                // with it. Purely visual — never takes a touch.
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final opacity = _hintStopped ? 0.0 : _hintHandOpacity;
                    if (opacity <= 0) return const SizedBox.shrink();
                    final thumbCenterX =
                        _position * maxDrag + 4 + thumbSize / 2;
                    return Positioned(
                      // touch_app's fingertip sits near the top-centre of
                      // the glyph, so centre it horizontally on the thumb
                      // and start it a little above the thumb's middle.
                      left: thumbCenterX - handSize * 0.42,
                      top: 4 + thumbSize / 2 - handSize * 0.12,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: _hintHandScale,
                            alignment: Alignment.topCenter,
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: handSize,
                    color: AppColors.textPrimary,
                    shadows: const [
                      Shadow(color: Colors.white, blurRadius: 6),
                      Shadow(color: Colors.white, blurRadius: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
