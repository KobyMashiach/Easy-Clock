// ignore_for_file: depend_on_referenced_packages, unused_local_variable

import 'package:easy_clock/helpers/clock_helper.dart';
import 'package:easy_clock/helpers/toast.dart';
import 'package:easy_clock/models/alarm_hive_storage.dart';
import 'package:easy_clock/models/data_models/alarm_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class AlarmModel extends ChangeNotifier {
  final AlarmsHiveLocalStorage _storage;

  AlarmState? state;
  List<AlarmDataModel>? alarms;
  bool loading = true;

  AlarmModel(AlarmsHiveLocalStorage storage) : _storage = storage {
    _storage.init().then((_) => loadAlarms());
  }

  @override
  void dispose() {
    _storage.dispose();
    super.dispose();
  }

  void loadAlarms() async {
    final alarms = await _storage.loadAlarms();
    alarms.sort(alarmSort);

    this.alarms = List.from(alarms);
    state = AlarmLoaded(alarms);
    loading = false;
    notifyListeners();
  }

  Future<void> addAlarm(AlarmDataModel alarm) async {
    bool newId = false, existAlarm = false;
    existAlarm = alarms!.any((element) => element.time == alarm.time);

    if (!existAlarm) {
      newId = alarms!.any((element) => element.id == alarm.id);

      if (newId) {
        AlarmDataModel temp =
            AlarmDataModel(time: alarm.time, weekdays: alarm.weekdays);
        alarm = temp;
      }
      loading = true;
      notifyListeners();

      final newAlarm = await _storage.addAlarm(alarm);
      alarms!.add(newAlarm);
      alarms!.sort(alarmSort);

      alarms = List.from(alarms!);

      loading = false;
      state = AlarmCreated(
        alarm,
        alarms!.indexOf(newAlarm),
      );
      notifyListeners();

      await _scheduleAlarm(alarm);
    } else {
      ToastMassageShort(
          msg:
              "The clock ${alarm.time.hour} : ${alarm.time.minute} is already set");
    }
  }

  Future<void> updateAlarm(AlarmDataModel alarm, int index) async {
    loading = true;
    notifyListeners();

    final newAlarm = await _storage.updateAlarm(alarm);

    alarms![index] = newAlarm;
    alarms!.sort(alarmSort);
    alarms = List.from(alarms!);

    loading = false;
    state = AlarmUpdated(
      newAlarm,
      alarm,
      index,
      alarms!.indexOf(newAlarm),
    );
    notifyListeners();

    await _removeScheduledAlarm(alarm);
    await _scheduleAlarm(newAlarm);
  }

  Future<void> deleteAlarm(AlarmDataModel alarm, int index) async {
    loading = true;
    notifyListeners();

    await _storage.removeAlarm(alarm);

    alarms!.removeAt(index);

    loading = false;
    state = AlarmDeleted(
      alarm,
      index,
    );
    notifyListeners();

    await _removeScheduledAlarm(alarm);
  }

  Future<void> deleteAllAlarms() async {
    loading = true;
    notifyListeners();

    await _storage.removeAllAlarm();

    alarms!.clear();

    loading = false;
    notifyListeners();

    await _removeAllScheduledAlarm();
  }

  int alarmSort(alarm1, alarm2) => alarm1.time.compareTo(alarm2.time);

  Future<void> _removeScheduledAlarm(AlarmDataModel alarm) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if (alarm.weekdays.isNotEmpty) {
      for (var notification in pendingNotificationRequests) {
        // get grouped id
        if ((notification.id / 10).floor() == alarm.id) {
          await flutterLocalNotificationsPlugin.cancel(notification.id);
        }
      }
    } else {
      await flutterLocalNotificationsPlugin.cancel(alarm.id);
    }
  }

  Future<void> _removeAllScheduledAlarm() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleAlarm(AlarmDataModel alarm) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm',
      'Alarm',
      channelDescription: 'Show the alarm',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(
      sound: 'alarm.aiff',
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    if (alarm.weekdays.isEmpty) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id,
        'Alarm at ${fromTimeToString(alarm.time)}',
        'Easy Clock',
        TZDateTime.local(
          alarm.time.year,
          alarm.time.month,
          alarm.time.day,
          alarm.time.hour,
          alarm.time.minute,
        ),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      for (var weekday in alarm.weekdays) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          // acts as an id, for cancelling later
          alarm.id * 10 + weekday,
          'Alarm at ${fromTimeToString(alarm.time)}',
          'Easy Clock',
          TZDateTime.local(
            alarm.time.year,
            alarm.time.month,
            alarm.time.day - alarm.time.weekday + weekday,
            alarm.time.hour,
            alarm.time.minute,
          ),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }
}

abstract class AlarmState {
  const AlarmState();
}

class AlarmLoaded extends AlarmState {
  final List<AlarmDataModel> alarms;

  const AlarmLoaded(this.alarms);
}

// state for create, update, delete,
class AlarmCreated extends AlarmState {
  final AlarmDataModel alarm;
  final int index;

  const AlarmCreated(this.alarm, this.index);
}

class AlarmDeleted extends AlarmState {
  final AlarmDataModel alarm;
  final int index;

  const AlarmDeleted(this.alarm, this.index);
}

class AlarmUpdated extends AlarmState {
  final AlarmDataModel alarm;
  final AlarmDataModel oldAlarm;
  final int index;
  final int newIndex;

  const AlarmUpdated(this.alarm, this.oldAlarm, this.index, this.newIndex);
}
