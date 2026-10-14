class Student {
  final String id;
  final String name;
  final int age;

  const Student({
    required this.id,
    required this.name,
    required this.age,
  });

  @override
  String toString() => 'Student(id: $id, name: $name, age: $age)';

  Student copyWith({String? id, String? name, int? age}) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}
