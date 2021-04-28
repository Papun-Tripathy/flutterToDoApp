import 'package:flutter/material.dart';

class Task {
  int id;
  String title;
  DateTime date;
  String priority;
  int status;     // 0 - incomplete, 1 - complete
  TimeOfDay time;

  Task({this.date, this.priority, this.status, this.title, this.time});
  Task.withId({this.id, this.date, this.priority, this.status, this.title,this.time});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    map['time'] = time.toString();

    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    // 12:55 PM
    print('time is: ');
    print(map['time']);
    String wholeTime = map['time'];
    int hour = int.parse(wholeTime.substring(10,12));
    int minute = int.parse(wholeTime.substring(13,15));
    TimeOfDay timme = TimeOfDay.now();
    timme.replacing(hour: hour, minute: minute);
    return Task.withId(
        id: map['id'],
        date: DateTime.parse(map['date']),
        title: map['title'],
        priority: map['priority'],
        time: timme,
        status: map['status']);
  }
}
