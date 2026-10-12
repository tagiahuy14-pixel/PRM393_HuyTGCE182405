class Student {
  final String id;
  final String name;
  bool isSelected;

  Student({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
}
