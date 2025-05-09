class MotivationTip {
  final String title;
  final String body;
  final DateTime? timestamp;

  MotivationTip({
    required this.title, 
    required this.body, 
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  factory MotivationTip.fromMap(Map<String, dynamic> map) {
    return MotivationTip(
      title: map['title'],
      body: map['body'],
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp']) 
          : null,
    );
  }
}