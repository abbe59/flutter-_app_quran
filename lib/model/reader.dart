class Reader {
  final String id;
  final String name;

  Reader({required this.id, required this.name});

  factory Reader.fromJson(Map<String, dynamic> json) {
    return Reader(id: json['id'].toString(), name: json['name']);
  }
}
