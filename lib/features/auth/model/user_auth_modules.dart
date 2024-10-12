import 'dart:convert';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? token;

  const User({
    this.id,
    this.name,
    this.email,
    this.token,
  });

  // copyWith method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }

  // Create from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  List<Object?> get props => [id, name, email, token];

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, token: $token)';
}
