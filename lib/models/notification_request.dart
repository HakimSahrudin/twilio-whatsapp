class NotificationRequest {
  final String to;
  final String message;
  final String? date;
  final String? time;

  NotificationRequest({
    required this.to,
    required this.message,
    this.date,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'message': message,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
    };
  }
}
