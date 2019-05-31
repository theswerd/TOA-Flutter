import 'dart:convert';

class User {
  User({
    this.displayName,
    this.photoURL,
    this.team,
    this.level = 1,
    this.favoriteTeams,
    this.favoriteEvents
  });

  final String displayName;
  final String photoURL;
  final String team;
  final int level;
  final List<String> favoriteTeams;
  final List<String> favoriteEvents;

  static User fromResponse(String response) {
    return User.fromMap(jsonDecode(response));
  }

  factory User.fromMap(Map<String, dynamic> map){
    return User(
        displayName: map['displayName'],
        photoURL: map['photoURL'],
        team: map['team'],
        level: map['level'],
        favoriteTeams: List<String>.from(map['favorite_teams']),
        favoriteEvents: List<String>.from(map['favorite_events'])
    );
  }
}