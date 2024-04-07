import 'package:dan_xi/common/constant.dart';
import 'package:dan_xi/generated/l10n.dart';
import 'package:dan_xi/model/time_table.dart';
import 'package:dan_xi/provider/settings_provider.dart';
import 'package:dan_xi/util/platform_universal.dart';
import 'package:dan_xi/widget/dialogs/manually_add_course_dialog_sub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


class ManuallyAddCourseDialog extends HookConsumerWidget {
  const ManuallyAddCourseDialog(this.courseAvailableList, {super.key});

  final List<int> courseAvailableList;

  Course newCourseListGenerator(
      TextEditingController courseNameController,
      TextEditingController courseIdController,
      TextEditingController courseRoomNameController,
      TextEditingController courseTeacherNameController,
      List<int> courseAvailableList,
      Course newCourse) {
    newCourse.courseName = courseNameController.text;
    newCourse.courseId = courseIdController.text;
    newCourse.roomId = "999999";
    newCourse.teacherNames = courseTeacherNameController.text.split(" ");
    newCourse.availableWeeks = courseAvailableList;
    newCourse.roomName = courseRoomNameController.text;
    newCourse.teacherIds = [""];

    return newCourse;
  }

  String slotsOfADayGenerator(List<CourseTime> courseTime) {
    List<String>? outCome = [];
    for (var element in courseTime) {
      outCome.add((element.slot + 1).toString());
    }
    return outCome.join(",");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseNameController = useTextEditingController();
    final courseIdController = useTextEditingController();
    final courseRoomIdController = useTextEditingController();
    final courseTeacherNameController = useTextEditingController();

    void onButtonPressed() async {
    List<CourseTime>? courseTime = await showDialog<List<CourseTime>>(
        context: context, builder: (context) => const AddCourseDialogSub());
    if (courseTime != null) {
      newCourse.times!.addAll(courseTime);
      selectedCourseTimeInfo.add(
        ListTile(
            title: Text(
                "${Constant.WeekDays[courseTime[0].weekDay]} ${slotsOfADayGenerator(courseTime)}")),
      );
    }
  }

    return AlertDialog(
      title: Text(S.of(context).add_courses),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: courseNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: S.of(context).course_name,
                  icon: const Icon(Icons.book)),
              autofocus: false,
            ),
            if (!PlatformX.isMaterial(context)) const SizedBox(height: 2),
            TextField(
              controller: courseIdController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: S.of(context).course_id,
                  icon: PlatformX.isMaterial(context)
                      ? const Icon(Icons.numbers)
                      : const Icon(CupertinoIcons.number)),
              autofocus: false,
            ),
            if (!PlatformX.isMaterial(context)) const SizedBox(height: 2),
            TextField(
              controller: courseRoomIdController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: S.of(context).course_room_name,
                  icon: PlatformX.isMaterial(context)
                      ? const Icon(Icons.location_city)
                      : const Icon(CupertinoIcons.location_fill)),
              autofocus: false,
            ),
            if (!PlatformX.isMaterial(context)) const SizedBox(height: 2),
            TextField(
              controller: courseTeacherNameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: S.of(context).course_teacher_name,
                  icon: PlatformX.isMaterial(context)
                      ? const Icon(Icons.people)
                      : const Icon(CupertinoIcons.person_2_fill)),
              autofocus: false,
            ),
            if (!PlatformX.isMaterial(context)) const SizedBox(height: 20),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: S.of(context).course_available_week,
                icon: PlatformX.isMaterial(context)
                    ? const Icon(Icons.calendar_month_outlined)
                    : const Icon(CupertinoIcons.calendar),
                enabled: false,
              ),
              autofocus: false,
            ),
            ListTile(
              title: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(18, (index) => index + 1)
                    .map((e) => GestureDetector(
                          onTap: () {
                            if (courseAvailableList.contains(e)) {
                              courseAvailableList.remove(e);
                            } else {
                              courseAvailableList.add(e);
                            }
                          },
                          child: CircleAvatar(
                            key: ObjectKey(e),
                            radius: 15.0,
                            backgroundColor: Color(ref.read(settingsProvider).get(SettingsProvider.primarySwatch)),
                            foregroundColor: Colors.white,
                            child: courseAvailableList.contains(e)
                                ? Icon(PlatformX.isMaterial(context)
                                    ? Icons.done
                                    : CupertinoIcons.checkmark_alt)
                                : Text(
                                    "$e",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            if (!PlatformX.isMaterial(context)) const SizedBox(height: 2),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: S.of(context).course_schedule,
                icon: PlatformX.isMaterial(context)
                    ? const Icon(Icons.access_time)
                    : const Icon(CupertinoIcons.time),
                enabled: false,
              ),
              autofocus: false,
            ),
            Column(
              children: selectedCourseTimeInfo,
            ),
            PlatformX.isMaterial(context)
                ? ElevatedButton(
                    onPressed: onButtonPressed,
                    child: Text(S.of(context).add_class_time))
                : CupertinoButton(
                    onPressed: onButtonPressed,
                    child: Text(S.of(context).add_class_time)),
          ],
        ),
      ),
      actions: [
        TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () => {Navigator.pop(context)}),
        TextButton(
            child: Text(S.of(context).ok),
            onPressed: () {
              if (courseAvailableList.isEmpty ||
                  newCourse.times!.isEmpty) {
                showPlatformDialog(
                    context: context,
                    builder: (BuildContext context) => PlatformAlertDialog(
                          title: Text(S.of(context).warning),
                          content: Text(S.of(context).invalid_course_info),
                          actions: [
                            PlatformDialogAction(
                              child: Text(S.of(context).ok),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ));
              } else {
                Navigator.pop(
                    context,
                    newCourseListGenerator(
                        courseNameController,
                        courseIdController,
                        courseRoomIdController,
                        courseTeacherNameController,
                        courseAvailableList,
                        newCourse));
              }
            }),
      ],
    );
  }
}

class _ManuallyAddCourseDialogState extends State<ManuallyAddCourseDialog> {
  Course newCourse = Course()..times = [];
  List<Widget> selectedCourseTimeInfo = [];

  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseIdController = TextEditingController();
  TextEditingController courseRoomIdController = TextEditingController();
  TextEditingController courseTeacherNameController = TextEditingController();
}
