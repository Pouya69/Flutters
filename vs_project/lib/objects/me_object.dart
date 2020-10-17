import 'dart:convert';

Me meFromJson(String str) {
  final jsonData = json.decode(str);
  return Me.fromMap(jsonData);
}

String meToJson(Me data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Me {
  final String username;
  final String password;
  final String email;
  final String date_of_birth;
  final String first_name;
  final String last_name;
  final String feelings;
  final int gender;
  final String chatlist;
  final String friendlist;

  Me(
      {this.username,
      this.friendlist,
      this.password,
      this.email,
      this.feelings,
      this.date_of_birth,
      this.first_name,
      this.last_name,
      this.gender,
      this.chatlist});

  factory Me.fromMap(Map<String, dynamic> json) => new Me(
        username: json["username"],
        first_name: json["first_name"],
        last_name: json["last_name"],
        password: json["password"],
        friendlist: json["friendlist"],
        email: json["email"],
        date_of_birth: json["date_of_birth"],
        gender: json["gender"],
        chatlist: json["chatlist"],
        feelings: json["feelings"],
      );

  Map<String, dynamic> toMap() => {
        "username": username,
        "first_name": first_name,
        "friendlist": friendlist,
        "last_name": last_name,
        "password": password,
        "email": email,
        "date_of_birth": date_of_birth,
        "gender": gender,
        "chatlist": chatlist,
        "feelings": feelings,
      };
}
