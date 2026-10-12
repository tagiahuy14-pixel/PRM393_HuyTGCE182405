import 'package:flutter/material.dart';

class Plan {
  final String title;
  final DateTime date;
  final TimeOfDay time;

  const Plan({
    required this.title,
    required this.date,
    required this.time,
  });
}
