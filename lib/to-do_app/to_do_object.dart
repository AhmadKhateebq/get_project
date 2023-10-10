class ToDo{
  DateTime date;
  String name;
  String? id;
  ToDo({required this.date,required this.name,this.id});
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'name': name,
      'id': id,
    };
  }
  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      date: DateTime.parse(map['date']),
      name: map['name'],
      id: map['id'],
    );
  }

}