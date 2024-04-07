/*
 *     Copyright (C) 2021  DanXi-Dev
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:dan_xi/common/constant.dart';
import 'package:dan_xi/generated/l10n.dart';
import 'package:dan_xi/model/celebration.dart';
import 'package:dan_xi/model/dashboard_card.dart';
import 'package:dan_xi/model/extra.dart';
import 'package:dan_xi/model/opentreehole/jwt.dart';
import 'package:dan_xi/model/opentreehole/tag.dart';
import 'package:dan_xi/model/time_table.dart';
import 'package:dan_xi/page/opentreehole/hole_editor.dart';
import 'package:dan_xi/provider/settings_item.dart';
import 'package:dan_xi/util/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Reference: https://github.com/JingYiJun/DanXi/blob/main/lib/repository/settings/settings_repository.dart

/// A class to manage [SharedPreferences] Settings
///
/// Code Integrity Note:
/// Avoid returning [null] in [SettingsProvider]. Return the default value instead.
/// Only return [null] when there is no default value.
class SettingsProvider extends ChangeNotifier {
  late XSharedPreferences preferences;
  static final _instance = SettingsProvider._();

  SettingsProvider._();

  factory SettingsProvider.getInstance() => _instance;

  static final campus = DecoratedSettingsItem(
      StringSettingsItem("campus", ""),
      (cam) => cam.toChineseName(),
      (str) => CampusEx.fromChineseName(str) ?? Campus.HANDAN_CAMPUS,
      overrideDefault: Campus.HANDAN_CAMPUS);

  static final fduholeToken =
      DecoratedSettingsItem<String, JWToken?>(StringSettingsItem("fduhole_token", ""),
          (tok) => jsonEncode(tok), (str) {
    try {
      return JWToken.fromJsonWithVerification(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }, overrideDefault: null);

  static final fduholeSortOrder =
      DecoratedSettingsItem(
          StringSettingsItem("fduhole_sortorder", ""),
          (order) => order.internalString(),
          (str) => SortOrderEx.fromInternalString(str) ?? SortOrder.LAST_REPLIED,
          overrideDefault: SortOrder.LAST_REPLIED);

  static final lastECBuildingChoiceRepresentation =
      IntSettingsItem("ec_last_choice", 0);

  static final fduholeFoldBehavior =
      DecoratedSettingsItem(
          StringSettingsItem("fduhole_foldbehavior", ""),
          (fld) => fld.internalString(),
          (str) => FoldBehaviorEx.fromInternalString(str) ?? FoldBehavior.FOLD,
          overrideDefault: FoldBehavior.FOLD);

  static final
      dashboardWidgetsSequence = DecoratedSettingsItem(
          StringSettingsItem("dashboard_widgets_json", ""),
          (tte) => jsonEncode(tte), (str) {
    var rawCardList = (jsonDecode(str) as List)
        .map((i) => DashboardCard.fromJson(i))
        .toList();
    // Merge new features which are added in the new version.
    for (var element in Constant.defaultDashboardCardList) {
      if (!element.isSpecialCard &&
          !rawCardList
              .any((card) => card.internalString == element.internalString)) {
        rawCardList.add(element);
      }
    }
    return rawCardList;
  }, overrideDefault: Constant.defaultDashboardCardList);

  static final thisSemesterStartDate =
      StringSettingsItem("this_semester_start_date", "");

  static final semesterStartDates =
      DecoratedSettingsItem<String, TimeTableExtra?>(
          StringSettingsItem("semester_start_dates", ""),
          (tte) => jsonEncode(tte),
          (str) => TimeTableExtra.fromJson(jsonDecode(str)),
          overrideDefault: null);

  static final cleanMode =
      BoolSettingsItem("clean_mode", false);

  static final debugMode = BoolSettingsItem("DEBUG", false);

  static final isAdEnabled =
      BoolSettingsItem("ad_enabled", false);

  static final hiddenTags =
      DecoratedSettingsItem(
          StringSettingsItem("hidden_tags", "[]"),
          (lst) => jsonEncode(lst),
          (str) => (json.decode(str) as List)
              .map<OTTag>((e) => OTTag.fromJson(e))
              .toList());

  static final hideHole = BoolSettingsItem("hideHole", false);

  static final useAccessibilityColoring =
      BoolSettingsItem("accessibility_coloring", false);

  static final celebrationWords =
      DecoratedSettingsItem(
          StringSettingsItem("celebration", Constant.SPECIAL_DAYS),
          (lst) => jsonEncode(lst),
          (str) => (json.decode(str) as List)
              .map<Celebration>((e) => Celebration.fromJson(e))
              .toList());

  static final backgroundImagePath =
      StringSettingsItem("background", "");

  static final searchHistory =
      ListSettingsItem<String>("search_history", []);

  static final timetableSemester =
      StringSettingsItem("timetable_semester", "");

  static final customUserAgent =
      StringSettingsItem("custom_user_agent", "");

  static final isBannerEnabled =
      BoolSettingsItem("banner_enabled", true);

  static final primarySwatch =
      IntSettingsItem("primary_swatch_ex", Colors.blue.value);

  static final language =
      DecoratedSettingsItem(
          StringSettingsItem("language", ""),
          (lan) => lan.toChineseName(),
          (str) => LanguageEx.fromChineseName(str) ?? defaultLanguage,
          overrideDefault: defaultLanguage);

  static final manualAddedCourses =
      DecoratedSettingsItem<String, List<Course>>(
          StringSettingsItem("new_courses", ""),
          (lst) => jsonEncode(lst),
          (str) => (json.decode(str) as List)
              .map<Course>((i) => Course.fromJson(i))
              .toList(),
          overrideDefault: []);

  static final isTagSuggestionEnabled =
      BoolSettingsItem("tag_suggestions", true);

  static final lightWatermarkColor =
      IntSettingsItem("light_watermark_color", 0x03000000);

  static final darkWatermarkColor =
      IntSettingsItem("dark_watermark_color", 0x09000000);

  static final visibleWatermarkMode =
      BoolSettingsItem("visible_watermark", false);

  static final hiddenHoles =
      ListSettingsItem<int>("hidden_holes", []);

  static final hiddenNotifications =
      ListSettingsItem<String>("hidden_notifications", []);

  static final themeType =
      DecoratedSettingsItem(
          StringSettingsItem("theme_type", ""),
          (type) => type.internalString(),
          (str) => ThemeTypeEx.fromInternalString(str) ?? ThemeType.SYSTEM,
          overrideDefault: ThemeType.SYSTEM);

  static final markdownEnabled =
      BoolSettingsItem("markdown_rendering_enabled", true);

  static final hasVisitedTimetable =
      BoolSettingsItem("visited_timetable", false);

  static final fduholeBaseUrl =
      StringSettingsItem("fduhole_base_url", Constant.FDUHOLE_BASE_URL);

  static final authBaseUrl =
      StringSettingsItem("auth_base_url", Constant.AUTH_BASE_URL);

  static final imageBaseUrl =
      StringSettingsItem("image_base_url", Constant.IMAGE_BASE_URL);

  static final danxiBaseUrl =
      StringSettingsItem("danke_base_url", Constant.DANKE_BASE_URL);

  FileImage? get backgroundImage {
    final path = "";
    if (path.isEmpty) return null;
    try {
      final File image = File(path);
      return FileImage(image);
    } catch (ignored) {
      return null;
    }
  }

  Future<void> init() async =>
      preferences = await XSharedPreferences.getInstance();

  static Language get defaultLanguage {
    Locale locale = PlatformDispatcher.instance.locale;
    if (locale.languageCode == 'en') {
      return Language.ENGLISH;
    } else if (locale.languageCode == 'ja') {
      return Language.JAPANESE;
    } else {
      return Language.SIMPLE_CHINESE;
    }
  }

  /*Push Token
  String? get lastPushToken {
    if (preferences!.containsKey(KEY_LAST_PUSH_TOKEN)) {
      return preferences!.getString(KEY_LAST_PUSH_TOKEN)!;
    }
    return null;
  }

  set lastPushToken(String? value) =>
      preferences!.setString(KEY_LAST_PUSH_TOKEN, value!);*/

  void deleteAllFduholeData() {
    fduholeToken.removeKey();
    fduholeFoldBehavior.removeKey();
    fduholeSortOrder.removeKey();
    hideHole.removeKey();
    hiddenHoles.removeKey();
  }

  bool tagSuggestionAvailable = false;

  Future<bool> isTagSuggestionAvailable() async {
    return await getTagSuggestions('test') != null;
  }
}

final settingsProvider = ChangeNotifierProvider<SettingsProvider>((ref) {
  return SettingsProvider.getInstance();
});

enum SortOrder { LAST_REPLIED, LAST_CREATED }

extension SortOrderEx on SortOrder {
  String? displayTitle(BuildContext context) {
    switch (this) {
      case SortOrder.LAST_REPLIED:
        return S.of(context).last_replied;
      case SortOrder.LAST_CREATED:
        return S.of(context).last_created;
    }
  }

  String internalString() {
    switch (this) {
      case SortOrder.LAST_REPLIED:
        return "time_updated";
      case SortOrder.LAST_CREATED:
        return "time_created";
    }
  }

  static SortOrder? fromInternalString(String str) {
    switch (str) {
      case "time_updated":
        return SortOrder.LAST_REPLIED;
      case "time_created":
        return SortOrder.LAST_CREATED;
      default:
        return null;
    }
  }
}

//FDUHOLE Folded Post Behavior
enum FoldBehavior { SHOW, FOLD, HIDE }

extension FoldBehaviorEx on FoldBehavior {
  String? displayTitle(BuildContext context) {
    switch (this) {
      case FoldBehavior.FOLD:
        return S.of(context).fold;
      case FoldBehavior.HIDE:
        return S.of(context).hide;
      case FoldBehavior.SHOW:
        return S.of(context).show;
    }
  }

  String internalString() {
    switch (this) {
      case FoldBehavior.FOLD:
        return 'fold';
      case FoldBehavior.HIDE:
        return 'hide';
      case FoldBehavior.SHOW:
        return 'show';
    }
  }

  static FoldBehavior? fromInternalString(String? str) {
    switch (str) {
      case 'fold':
        return FoldBehavior.FOLD;
      case 'hide':
        return FoldBehavior.HIDE;
      case 'show':
        return FoldBehavior.SHOW;
      default:
        return null;
    }
  }
}

enum OTNotificationTypes { MENTION, FAVORITE, REPORT }

extension OTNotificationTypesEx on OTNotificationTypes {
  String? displayTitle(BuildContext context) {
    switch (this) {
      case OTNotificationTypes.MENTION:
        return S.of(context).notification_mention;
      case OTNotificationTypes.FAVORITE:
        return S.of(context).notification_favorite;
      case OTNotificationTypes.REPORT:
        return S.of(context).notification_reported;
    }
  }

  String? displayShortTitle(BuildContext context) {
    switch (this) {
      case OTNotificationTypes.MENTION:
        return S.of(context).notification_mention_s;
      case OTNotificationTypes.FAVORITE:
        return S.of(context).notification_favorite_s;
      case OTNotificationTypes.REPORT:
        return S.of(context).notification_reported_s;
    }
  }

  String internalString() {
    switch (this) {
      case OTNotificationTypes.MENTION:
        return 'mention';
      case OTNotificationTypes.FAVORITE:
        return 'favorite';
      case OTNotificationTypes.REPORT:
        return 'report';
    }
  }

  static OTNotificationTypes? fromInternalString(String str) {
    switch (str) {
      case 'mention':
        return OTNotificationTypes.MENTION;
      case 'favorite':
        return OTNotificationTypes.FAVORITE;
      case 'report':
        return OTNotificationTypes.REPORT;
      default:
        return null;
    }
  }
}

enum ThemeType { LIGHT, DARK, SYSTEM }

extension ThemeTypeEx on ThemeType {
  String? displayTitle(BuildContext context) {
    switch (this) {
      case ThemeType.LIGHT:
        return S.of(context).theme_type_light;
      case ThemeType.DARK:
        return S.of(context).theme_type_dark;
      case ThemeType.SYSTEM:
        return S.of(context).theme_type_system;
    }
  }

  String internalString() {
    switch (this) {
      case ThemeType.LIGHT:
        return 'light';
      case ThemeType.DARK:
        return 'dark';
      case ThemeType.SYSTEM:
        return 'system';
    }
  }

  static ThemeType? fromInternalString(String? str) {
    switch (str) {
      case 'light':
        return ThemeType.LIGHT;
      case 'dark':
        return ThemeType.DARK;
      case 'system':
        return ThemeType.SYSTEM;
      default:
        return null;
    }
  }

  Brightness getBrightness() {
    switch (this) {
      case ThemeType.LIGHT:
        return Brightness.light;
      case ThemeType.DARK:
        return Brightness.dark;
      case ThemeType.SYSTEM:
        return WidgetsBinding.instance.window.platformBrightness;
    }
  }
}
