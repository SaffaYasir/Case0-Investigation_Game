import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String rank;
  final int xp;
  final int casesCompleted;
  final int totalScore;
  final List<String> badges;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.rank,
    required this.xp,
    this.casesCompleted = 0,
    this.totalScore = 0,
    this.badges = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'rank': rank,
      'xp': xp,
      'createdAt': createdAt,
      'casesCompleted': casesCompleted,
      'totalScore': totalScore,
      'badges': badges,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      rank: map['rank'] as String,
      xp: map['xp'] as int,
      casesCompleted: map['casesCompleted'] as int? ?? 0,
      totalScore: map['totalScore'] as int? ?? 0,
      badges: (map['badges'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}