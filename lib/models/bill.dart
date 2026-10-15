class Bill {
  const Bill({
    this.id,
    required this.billName,
    required this.category,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  final int? id;
  final String billName;
  final String category;
  final double amount;
  final String status;
  final String dueDate;

  Map<String, dynamic> toMap() => {
    'id': id,
    'bill_name': billName,
    'category': category,
    'amount': amount,
    'status': status,
    'due_date': dueDate,
  };

  factory Bill.fromMap(Map<String, dynamic> map) => Bill(
    id: map['id'] as int?,
    billName: map['bill_name'] as String,
    category: map['category'] as String,
    amount: (map['amount'] as num).toDouble(),
    status: map['status'] as String,
    dueDate: map['due_date'] as String,
  );
}
