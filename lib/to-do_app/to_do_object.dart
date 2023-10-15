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

  @override
  String toString() {
    return 'ToDo{date: $date, name: $name, id: $id}';
  }

  factory ToDo.fromJson(String key, Map<String, dynamic> value){
    return ToDo(
        id: key, name: value['name']!, date: DateTime.parse(value['date']!));
  }

}