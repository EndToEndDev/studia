class NotificationItem {
    final int? id;
    final int userId;
    final String title;
    final String body;
    final bool read;
    final String? createdAt;

    NotificationItem({
        this.id,
        required this.userId,
        required this.title,
        required this.body,
        required this.read,
        this.createdAt,
    });

    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'user_id': userId,
            'title': title,
            'body': body,
            'read_flag': read ? 1 : 0,
            'created_at': createdAt,
        };
    }

    factory NotificationItem.fromMap(Map<String, dynamic> map) {
        return NotificationItem(
            id: map['id'],
            userId: map['user_id'],
            title: map['title'],
            body: map['body'],
            read: map['read_flag'] == 1,
            createdAt: map['created_at'],
        );
    }
}