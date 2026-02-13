class Vendor {
  int? id;
  String name;
  String phone;

  Vendor({this.id, required this.name, required this.phone});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
      };

  factory Vendor.fromMap(Map<String, dynamic> map) => Vendor(
        id: map['id'],
        name: map['name'],
        phone: map['phone'],
      );
}
