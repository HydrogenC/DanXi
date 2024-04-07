import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/constant.dart';
import '../../generated/l10n.dart';
import '../../model/time_table.dart';
import '../../provider/settings_provider.dart';

class AddCourseDialogSub extends HookConsumerWidget {
  const AddCourseDialogSub({super.key});

  List<CourseTime>? newCourseTimeGenerator(
      int selectedWeekDay, List<bool> selectedSlots) {
    List<CourseTime>? newCourseTime = [];
    int index = 0;
    for (var element in selectedSlots) {
      if (element == true) {
        newCourseTime.add(CourseTime(selectedWeekDay, index));
      }
      index++;
    }
    return newCourseTime;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeekDay = useState(0);

    // To make the list notifiable
    final slotsModified = useState(false);
    List<bool> selectedSlots = List.generate(15, (index) => false);

    final bgColor =
        ref.read(settingsProvider).get(SettingsProvider.primarySwatch);

    return AlertDialog(
      content: Column(
        children: [
          Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(7, (index) => index)
                  .map((e) => GestureDetector(
                        onTap: () {
                          selectedWeekDay.value = e;
                        },
                        child: CircleAvatar(
                          radius: 24.0,
                          backgroundColor: Color(bgColor),
                          foregroundColor: Colors.white,
                          child: e == selectedWeekDay.value
                              ? const Icon(Icons.done)
                              : Text(
                                  Constant.WeekDays[e],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                                ),
                        ),
                      ))
                  .toList()),
          const SizedBox(height: 20),
          Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(14, (index) => index)
                  .map((e) => GestureDetector(
                        onTap: () {
                          selectedSlots[e] = !selectedSlots[e];
                          slotsModified.value = !slotsModified.value;
                        },
                        child: CircleAvatar(
                          radius: 24.0,
                          backgroundColor: Color(bgColor),
                          foregroundColor: Colors.white,
                          child: selectedSlots[e] == true
                              ? const Icon(Icons.done)
                              : Text(
                                  (e + 1).toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                                ),
                        ),
                      ))
                  .toList()),
        ],
      ),
      actions: [
        TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.pop(context)),
        TextButton(
            child: Text(S.of(context).add),
            onPressed: () {
              Navigator.pop(context,
                  newCourseTimeGenerator(selectedWeekDay.value, selectedSlots));
            }),
      ],
    );
  }
}
