class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? payload;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      payload: json['payload'],
      isRead: json['isRead'] ?? false,
    );
  }
}
