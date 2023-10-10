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

  factory ToDo.fromString(String data) {
    print(data);
    final keyValuePairs = data.split(', ');
    DateTime? parsedDate;
    String? parsedName;
    String? parsedId;

    // Iterate through key-value pairs and extract values
    for (final pair in keyValuePairs) {
      final parts = pair.split(': ');
      if (parts.length == 2) {
        final key = parts[0];
        final value = parts[1];
        if (key == 'date') {
          print(key);
          parsedDate = DateTime.parse(value);
        } else if (key == 'name') {
          parsedName = value;
        } else if (key == 'id') {
          parsedId = value;
        }
      }
    }

    if (parsedDate != null && parsedName != null) {
      return ToDo(
        date: parsedDate,
        name: parsedName,
        id: parsedId,
      );
    } else {
      throw FormatException('Invalid data format');
    }
  }
}