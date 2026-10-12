import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(student.name.isNotEmpty ? student.name[0] : '?'),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          student.id,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Icon(
          student.isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: student.isSelected ? Colors.green : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
