class NotificationResponse {
  final bool success;
  final String? sid;
  final String? error;

  NotificationResponse({
    required this.success,
    this.sid,
    this.error,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      sid: json['sid'],
      error: json['error'],
    );
  }
}
