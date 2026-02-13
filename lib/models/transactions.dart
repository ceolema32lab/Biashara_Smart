class TransactionModel {
  int? id;
  String description;
  double amount;
  String type; // "sales" or "expense"

  TransactionModel({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'amount': amount,
        'type': type,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'],
        description: map['description'],
        amount: map['amount'],
        type: map['type'],
      );
}
