import 'package:hive/hive.dart';

part 'staff.g.dart';

@HiveType(typeId: 2)
class Staff {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String role;
  
  @HiveField(3)
  final String phone;
  
  @HiveField(4)
  final String email;
  
  @HiveField(5)
  final DateTime? birthDate;
  
  @HiveField(6)
  final String? photo;
  
  @HiveField(7)
  final bool isActive;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime updatedAt;
  
  @HiveField(10)
  final String? notes;
  
  @HiveField(11)
  final String? qualifications;
  
  @HiveField(12)
  final int? experienceYears;
  
  @HiveField(13)
  final DateTime? joinedDate;
  
  @HiveField(14)
  final List<String>? permissions;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.birthDate,
    this.photo,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.qualifications,
    this.experienceYears,
    this.joinedDate,
    this.permissions,
  });

  // Calculate age if birthDate is available
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Get initials
  String get initials {
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  // Compatibility getters for older code
  String? get photoUrl => photo;
  String? get description => notes;

  // Check if staff has specific permission
  bool hasPermission(String permission) {
    if (permissions == null) return false;
    return permissions!.contains(permission);
  }

  // Copy with method for immutability
  Staff copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    String? email,
    DateTime? birthDate,
    String? photo,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? qualifications,
    int? experienceYears,
    DateTime? joinedDate,
    List<String>? permissions,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      photo: photo ?? this.photo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      qualifications: qualifications ?? this.qualifications,
      experienceYears: experienceYears ?? this.experienceYears,
      joinedDate: joinedDate ?? this.joinedDate,
      permissions: permissions ?? this.permissions,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
      'email': email,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'photo': photo,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'notes': notes,
      'qualifications': qualifications,
      'experienceYears': experienceYears,
      'joinedDate': joinedDate?.millisecondsSinceEpoch,
      'permissions': permissions,
    };
  }

  // From JSON
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      email: json['email'],
      birthDate: json['birthDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['birthDate'])
          : null,
      photo: json['photo'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      notes: json['notes'],
      qualifications: json['qualifications'],
      experienceYears: json['experienceYears'],
      joinedDate: json['joinedDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['joinedDate'])
          : null,
      permissions: json['permissions'] != null 
          ? List<String>.from(json['permissions'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Staff && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Staff(id: $id, name: $name, role: $role)';
  }
}


