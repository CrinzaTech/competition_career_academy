import 'package:dio/dio.dart';

import 'package:competition_career_academy/core/config/di/dependency_injection.dart';
import 'package:competition_career_academy/core/network/api_endpoints.dart';
import 'package:competition_career_academy/core/session/session_service.dart';
import 'package:competition_career_academy/core/utils/utils.dart';

/// Asks the backend "is this session still allowed?" so an admin's device
/// reset or block signs the learner out within seconds, not at whatever
/// API call happens next.
///
/// Triggers:
///  • the app coming back to the foreground (and once at startup), and
///  • a silent `force_logout` FCM push sent by web_admin on reset/block.
///
/// The check itself is just `GET session-check` through the shared Dio, so
/// [AuthInterceptor] does the rest: a 401 `session_revoked` /
/// `account_blocked` signs out with the institute's message; 200 changes
/// nothing. The push is only a wake-up call — the server decides — so a
/// push that arrives after the learner has legitimately logged in again
/// cannot sign them out.
class SessionWatchdog {
  SessionWatchdog._();

  /// Resume events can fire in quick bursts (permission dialogs, the share
  /// sheet, picture-in-picture). One check per window is plenty.
  static const Duration _minGap = Duration(seconds: 15);

  static DateTime? _lastCheck;
  static bool _inFlight = false;

  /// [force] skips the throttle — used for the push, which means "check now".
  static Future<void> check({bool force = false, String reason = ''}) async {
    if (_inFlight) return;
    if (!sl.isRegistered<SessionService>() || !sl.isRegistered<Dio>()) return;
    if (!sl<SessionService>().isLoggedIn) return;

    final now = DateTime.now();
    if (!force &&
        _lastCheck != null &&
        now.difference(_lastCheck!) < _minGap) {
      return;
    }

    _inFlight = true;
    _lastCheck = now;
    try {
      Utils.debugLog('SessionWatchdog: checking session ($reason)');
      await sl<Dio>().get(ApiEndpoints.sessionCheck);
    } catch (_) {
      // 401s are acted on by AuthInterceptor; offline / 5xx simply leave
      // the session alone until the next trigger.
    } finally {
      _inFlight = false;
    }
  }
}
