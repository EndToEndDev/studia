class Message {
  final int? id;
  final int senderId;
  final int receiverId;
  final String body;
  final String? sentAt;
  final bool read;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.body,
    this.sentAt,
    required this.read,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'body': body,
      'sent_at': sentAt,
      'read_flag': read ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      body: map['body'],
      sentAt: map['sent_at'],
      read: map['read_flag'] == 1,
    );
  }
}