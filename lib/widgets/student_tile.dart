import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentTile extends StatelessWidget {
  const StudentTile({super.key, required this.student, this.onTap});

  final Student student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(student.name),
      subtitle: Text('ID: ${student.id} | Tuổi: ${student.age}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
