class Message {
  final String message;
  final int senderId;
  final int receiverId;
  final String senderType;
  final DateTime createdAt;

  Message({
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.senderType,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      senderType: json['sender_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
