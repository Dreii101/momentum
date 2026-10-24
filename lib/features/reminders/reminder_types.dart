enum ReminderKind { deadline, activity, work, timer }

enum RegistrationState {
  pending,
  scheduled,
  cancelled,
  elapsed,
  scheduleFailed,
  cancelFailed,
}

class NotificationCapability {
  const NotificationCapability({
    required this.supported,
    required this.allowed,
    required this.exact,
    required this.message,
  });
  final bool supported, allowed, exact;
  final String message;
}

class ReminderTarget {
  const ReminderTarget({
    required this.key,
    required this.ruleId,
    required this.sourceUtc,
    required this.dueUtc,
    required this.title,
    required this.body,
    this.originalDate,
    this.sessionId,
  });
  final String key, ruleId, title, body;
  final DateTime sourceUtc, dueUtc;
  final String? originalDate, sessionId;
}
