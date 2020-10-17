import 'dart:convert';

Chat meFromJson(String str) {
  final jsonData = json.decode(str);
  return Chat.fromMap(jsonData);
}

String chatToJson(Chat data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Chat {
  final String group_id;
  final String group_name;
  final String group_key;
  final String userlist;
  final String lastMessage;

  Chat({this.group_id, this.group_name, this.group_key, this.userlist, this.lastMessage});

  factory Chat.fromMap(Map<String, dynamic> json) => new Chat(
        group_id: json["group_id,"],
        group_name: json["group_name"],
        group_key: json["group_key"],
        userlist: json["userlist"],
        lastMessage: json["last_message"]
      );

  Map<String, dynamic> toMap() => {
        "group_id": group_id,
        "group_name": group_name,
        "group_key": group_key,
        "userlist": group_key,
        "last_message": lastMessage,
      };
}
