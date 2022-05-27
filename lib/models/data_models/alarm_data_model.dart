import 'dart:math';

import 'package:easy_clock/theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'alarm_data_model.g.dart';

@HiveType(typeId: 0)
class AlarmDataModel {
  @HiveField(0)
  late final int id;
  @HiveField(1)
  final DateTime time;
  @HiveField(2)
  final List<int> weekdays;

  AlarmDataModel({
    int? id,
    required this.time,
    required this.weekdays,
  }) {
    this.id = id ?? Random.secure().nextInt(10000 - 1000) + 1000;
  }

  AlarmDataModel copyWith({
    int? id,
    DateTime? time,
    List<int>? weekdays,
  }) =>
      AlarmDataModel(
        id: id ?? this.id,
        time: time ?? this.time,
        weekdays: weekdays != null ? List.from(weekdays) : this.weekdays,
      );
}

@HiveType(typeId: 1)
class SaveColorLocal {
  @HiveField(3)
  late Color mainColor = changeColor;

  SaveColorLocal({required Color color}) {
    mainColor = color;
  }

  SaveColorLocal changeColorLocal({Color? color}) =>
      SaveColorLocal(color: color ?? changeColor);
}
