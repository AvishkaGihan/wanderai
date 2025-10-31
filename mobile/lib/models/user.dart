import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart'; // The file that will be generated automatically

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.displayName,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Helper method for state management (used by Riverpod)
  User copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? displayName,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
