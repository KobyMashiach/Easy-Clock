// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:easy_clock/helpers/clock_helper.dart';
import 'package:easy_clock/models/data_models/alarm_data_model.dart';
import 'package:easy_clock/providers/alarm_provider.dart';
import 'package:easy_clock/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModifyAlarmScreenArg {
  final AlarmDataModel alarm;
  final int index;

  ModifyAlarmScreenArg(this.alarm, this.index);
}

class ModifyAlarmScreen extends StatefulWidget {
  static const routeName = '/modifyAlarm';

  final ModifyAlarmScreenArg? arg;

  const ModifyAlarmScreen({
    Key? key,
    this.arg,
  }) : super(key: key);

  @override
  State<ModifyAlarmScreen> createState() => _ModifyAlarmScreenState();
}

class _ModifyAlarmScreenState extends State<ModifyAlarmScreen> {
  late AlarmDataModel alarm = widget.arg?.alarm ??
      AlarmDataModel(
        time: DateTime.now(),
        weekdays: [],
      );

  late int saveH = 0;
  late int saveM = 0;
  late int count = 1;

  bool get _editing => widget.arg?.alarm != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_editing ? '      Update' : '      Create') + ' Alarm',
        ),
        leading: TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              bool haveFewAlarms = saveH + saveM != 0 ? true : false;
              final model = context.read<AlarmModel>();
              _editing
                  ? await model.updateAlarm(alarm, widget.arg!.index)
                  : await model.addAlarm(alarm);
              if (haveFewAlarms) {
                for (var i = 1; i <= count; i++) {
                  DateTime alarmTemp =
                      alarm.time.add(Duration(hours: saveH, minutes: saveM));
                  alarm = alarm.copyWith(time: alarmTemp);
                  _editing
                      ? await model.updateAlarm(alarm, widget.arg!.index)
                      : await model.addAlarm(alarm);
                }
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Theme.of(context).brightness,
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                onDateTimeChanged: (value) {
                  setState(() {
                    alarm = alarm.copyWith(time: value);
                  });
                },
                initialDateTime: alarm.time,
              ),
            ),
          ),
          ExpansionTile(
            title: Text(
              'Repeat',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            trailing: Text(
              alarm.weekdays.isEmpty
                  ? 'Never'
                  : alarm.weekdays.length == 7
                      ? 'Everyday'
                      : alarm.weekdays
                          .map((weekday) => fromWeekdayToStringShort(weekday))
                          .join(', '),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            children: List.generate(7, (index) => index + 1).map((weekday) {
              final checked = alarm.weekdays.contains(weekday);
              return CheckboxListTile(
                  title: Text(
                    fromWeekdayToString(weekday),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  value: checked,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setState(() {
                      (value ?? false)
                          ? alarm.weekdays.add(weekday)
                          : alarm.weekdays.remove(weekday);
                    });
                  });
            }).toList(),
          ),
          Expanded(
            child: Align(
              // alignment: FractionalOffset.bottomCenter,
              alignment: const Alignment(0, 0),
              child: MaterialButton(
                color: changeColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "Want add few alarm in 1 click?\nclick here",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: changeColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white),
                ),
                onPressed: () async {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                            title: const Text(
                              "Choose time",
                              style: TextStyle(fontSize: 30),
                            ),
                            actions: [chooseFewAlarms()],
                            cancelButton: CupertinoActionSheetAction(
                                child: const Text('Next'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (context) =>
                                          CupertinoActionSheet(
                                            title: const Text(
                                              "Choose how many clocks",
                                              style: TextStyle(fontSize: 30),
                                            ),
                                            actions: [
                                              chooseCount(),
                                            ],
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                                    child: const Text('Save'),
                                                    onPressed: () =>
                                                        Navigator.pop(context)),
                                          ));
                                }),
                          ));
                },
              ),
            ),
          ),
          Text(
            saveH + saveM == 0
                ? ""
                : "${count + 1} alarm\nevery $saveH Hours and $saveM Minutes\nfrom ${fromTimeToString(alarm.time)}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget chooseCount() => SizedBox(
        height: 250,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Theme.of(context).brightness,
          ),
          child: CupertinoPicker(
            itemExtent: 30,
            onSelectedItemChanged: (int value) {
              setState(() {
                count = value + 1;
              });
            },
            children: [
              for (var i = 2; i <= 30; i++) Text(i.toString()),
            ],
          ),
        ),
      );

  Widget chooseFewAlarms() => SizedBox(
        height: 250,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: Theme.of(context).brightness,
          ),
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            minuteInterval: 1,
            secondInterval: 1,
            onTimerDurationChanged: (Duration value) {
              setState(() {
                List<String> temp = value.toString().split(':');
                saveH = int.parse(temp[0]);
                saveM = int.parse(temp[1]);
              });
            },
          ),
        ),
      );
}
