import 'package:flutter/foundation.dart';

@immutable
class Department {
  final String id;
  final String name;
  final String code;

  const Department({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}
