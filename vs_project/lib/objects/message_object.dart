import 'dart:convert';

Message meFromJson(String str) {
  final jsonData = json.decode(str);
  return Message.fromMap(jsonData);
}

String chatToJson(Message data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Message {
  final int message_id;
  final int group_id;
  final String creator;
  final String replying_to;
  final String message;
  final String file;
  final int is_read;

  Message(
      {this.message_id,
      this.group_id,
      this.creator,
      this.replying_to,
      this.message,
      this.file,
      this.is_read});

  factory Message.fromMap(Map<String, dynamic> json) => new Message(
        message_id: json["message_id"],
        group_id: json["group_id"],
        creator: json["creator"],
        replying_to: json["replying_to"],
        message: json["message"],
        file: json["file"],
        is_read: json["is_read"],
      );

  Map<String, dynamic> toMap() => {
        "message_id": message_id,
        "group_id": group_id,
        "creator": creator,
        "replying_to": replying_to,
        "message": message,
        "file": file,
        "is_read": is_read,
      };
}
