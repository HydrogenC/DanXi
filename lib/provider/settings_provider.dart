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
import 'package:dan_xi/util/io/user_agent_interceptor.dart';
import 'package:dan_xi/util/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A class to manage [SharedPreferences] Settings
///
/// Code Integrity Note:
/// Avoid returning [null] in [SettingsController]. Return the default value instead.
/// Only return [null] when there is no default value.
class SettingsController extends GetxController {
  XSharedPreferences? preferences;
  static final _instance = SettingsController._();
  static const String KEY_PREFERRED_CAMPUS = "campus";

  //static const String KEY_AUTOTICK_LAST_CANCEL_DATE =
  //    "autotick_last_cancel_date";
  //static const String KEY_PREFERRED_THEME = "theme";
  static const String KEY_FDUHOLE_TOKEN = "fduhole_token_v3";
  static const String KEY_FDUHOLE_SORTORDER = "fduhole_sortorder";
  static const String KEY_EMPTY_CLASSROOM_LAST_BUILDING_CHOICE =
      "ec_last_choice";
  static const String KEY_FDUHOLE_FOLDBEHAVIOR = "fduhole_foldbehavior";
  static const String KEY_DASHBOARD_WIDGETS = "dashboard_widgets_json";
  static const String KEY_THIS_SEMESTER_START_DATE = "this_semester_start_date";
  static const String KEY_SEMESTER_START_DATES = "semester_start_dates";
  static const String KEY_CLEAN_MODE = "clean_mode";
  static const String KEY_DEBUG_MODE = "DEBUG";
  static const String KEY_AD_ENABLED = "ad_enabled";
  static const String KEY_HIDDEN_TAGS = "hidden_tags";
  static const String KEY_HIDDEN_TREEHOLE = "hidden_hole";
  static const String KEY_ACCESSIBILITY_COLORING = "accessibility_coloring";
  static const String KEY_CELEBRATION = "celebration";
  static const String KEY_BACKGROUND_IMAGE_PATH = "background";
  static const String KEY_SEARCH_HISTORY = "search_history";
  static const String KEY_TIMETABLE_SEMESTER = "timetable_semester";
  static const String KEY_CUSTOM_USER_AGENT = "custom_user_agent";
  static const String KEY_BANNER_ENABLED = "banner_enabled";
  static const String KEY_PRIMARY_SWATCH = "primary_swatch";
  static const String KEY_PRIMARY_SWATCH_V2 = "primary_swatch_v2";
  static const String KEY_PREFERRED_LANGUAGE = "language";
  static const String KEY_MANUALLY_ADDED_COURSE = "new_courses";
  static const String KEY_TAG_SUGGESTIONS_ENABLE = "tag_suggestions";
  static const String KEY_LIGHT_WATERMARK_COLOR = "light_watermark_color";
  static const String KEY_DARK_WATERMARK_COLOR = "dark_watermark_color";
  static const String KEY_VISIBLE_WATERMARK_MODE = "visible_watermark";
  static const String KEY_HIDDEN_HOLES = "hidden_holes";
  static const String KEY_HIDDEN_NOTIFICATIONS = "hidden_notifications";
  static const String KEY_THEME_TYPE = "theme_type";
  static const String KEY_MARKDOWN_ENABLED = "markdown_rendering_enabled";
  static const String KEY_VISITED_TIMETABLE = "visited_timetable";
  static const String KEY_FDUHOLE_BASE_URL = "fduhole_base_url";
  static const String KEY_AUTH_BASE_URL = "auth_base_url";
  static const String KEY_IMAGE_BASE_URL = "image_base_url";
  static const String KEY_DANKE_BASE_URL = "danke_base_url";

  SettingsController._();

  static SettingsController get to => Get.find();

  /// Get a global instance of [SettingsController].
  ///
  /// Never use it anywhere expect [main.dart], 
  /// If you need to get access to a [SettingsController], call [SettingsContoller.to] instead.
  factory SettingsController.getInstance() => _instance;

  List<String> get searchHistory {
    if (preferences!.containsKey(KEY_SEARCH_HISTORY)) {
      return preferences!.getStringList(KEY_SEARCH_HISTORY) ??
          List<String>.empty();
    }
    return List<String>.empty();
  }

  set searchHistory(List<String>? value) {
    if (value != null) {
      preferences!.setStringList(KEY_SEARCH_HISTORY, value);
    } else if (preferences!.containsKey(KEY_SEARCH_HISTORY)) {
      preferences!.remove(KEY_SEARCH_HISTORY);
    }
    update();
  }

  String? get timetableSemester {
    if (preferences!.containsKey(KEY_TIMETABLE_SEMESTER)) {
      return preferences!.getString(KEY_TIMETABLE_SEMESTER);
    }
    return null;
  }

  set timetableSemester(String? value) {
    preferences!.setString(KEY_TIMETABLE_SEMESTER, value!);
    update();
  }

  FileImage? get backgroundImage {
    final path = backgroundImagePath;
    if (path == null) return null;
    try {
      final File image = File(path);
      return FileImage(image);
    } catch (ignored) {
      return null;
    }
  }

  /// Set and get _BASE_URL, _BASE_AUTH_URL, _IMAGE_BASE_URL, _DANKE_BASE_URL for debug
  String get fduholeBaseUrl {
    if (preferences!.containsKey(KEY_FDUHOLE_BASE_URL)) {
      String? fduholeBaseUrl = preferences!.getString(KEY_FDUHOLE_BASE_URL);
      if (fduholeBaseUrl != null) {
        return fduholeBaseUrl;
      }
    }
    return Constant.FDUHOLE_BASE_URL;
  }

  set fduholeBaseUrl(String? value) {
    if (value != null) {
      preferences!.setString(KEY_FDUHOLE_BASE_URL, value);
    } else {
      preferences!.setString(KEY_FDUHOLE_BASE_URL, Constant.FDUHOLE_BASE_URL);
    }
    update();
  }

  String get authBaseUrl {
    if (preferences!.containsKey(KEY_AUTH_BASE_URL)) {
      String? authBaseUrl = preferences!.getString(KEY_AUTH_BASE_URL);
      if (authBaseUrl != null) {
        return authBaseUrl;
      }
    }
    return Constant.AUTH_BASE_URL;
  }

  set authBaseUrl(String? value) {
    if (value != null) {
      preferences!.setString(KEY_AUTH_BASE_URL, value);
    } else {
      preferences!.setString(KEY_AUTH_BASE_URL, Constant.AUTH_BASE_URL);
    }
    update();
  }

  String get imageBaseUrl {
    if (preferences!.containsKey(KEY_IMAGE_BASE_URL)) {
      String? imageBaseUrl = preferences!.getString(KEY_IMAGE_BASE_URL);
      if (imageBaseUrl != null) {
        return imageBaseUrl;
      }
    }
    return Constant.IMAGE_BASE_URL;
  }

  set imageBaseUrl(String? value) {
    if (value != null) {
      preferences!.setString(KEY_IMAGE_BASE_URL, value);
    } else {
      preferences!.setString(KEY_IMAGE_BASE_URL, Constant.IMAGE_BASE_URL);
    }
    update();
  }

  String get dankeBaseUrl {
    if (preferences!.containsKey(KEY_DANKE_BASE_URL)) {
      String? dankeBaseUrl = preferences!.getString(KEY_DANKE_BASE_URL);
      if (dankeBaseUrl != null) {
        return dankeBaseUrl;
      }
    }
    return Constant.DANKE_BASE_URL;
  }

  set dankeBaseUrl(String? value) {
    if (value != null) {
      preferences!.setString(KEY_DANKE_BASE_URL, value);
    } else {
      preferences!.setString(KEY_DANKE_BASE_URL, Constant.DANKE_BASE_URL);
    }
    update();
  }

  String? get backgroundImagePath {
    if (preferences!.containsKey(KEY_BACKGROUND_IMAGE_PATH)) {
      return preferences!.getString(KEY_BACKGROUND_IMAGE_PATH)!;
    }
    return null;
  }

  set backgroundImagePath(String? value) {
    if (value != null) {
      preferences!.setString(KEY_BACKGROUND_IMAGE_PATH, value);
    } else {
      preferences!.remove(KEY_BACKGROUND_IMAGE_PATH);
    }
    update();
  }

  Future<void> init() async =>
      preferences = await XSharedPreferences.getInstance();

  bool get useAccessibilityColoring {
    if (preferences!.containsKey(KEY_ACCESSIBILITY_COLORING)) {
      return preferences!.getBool(KEY_ACCESSIBILITY_COLORING)!;
    }
    return false;
  }

  set useAccessibilityColoring(bool value) {
    preferences!.setBool(KEY_ACCESSIBILITY_COLORING, value);
    update(['global']);
  }

  /// Whether user has opted-in to Ads
  bool get isAdEnabled {
    if (preferences!.containsKey(KEY_AD_ENABLED)) {
      return preferences!.getBool(KEY_AD_ENABLED)!;
    }
    return false;
  }

  set isAdEnabled(bool value) {
    preferences!.setBool(KEY_AD_ENABLED, value);
    update();
  }

  bool get hasVisitedTimeTable {
    if (preferences!.containsKey(KEY_VISITED_TIMETABLE)) {
      return preferences!.getBool(KEY_VISITED_TIMETABLE)!;
    }
    return false;
  }

  set hasVisitedTimeTable(bool value) {
    preferences!.setBool(KEY_VISITED_TIMETABLE, value);
    update();
  }

  int get lastECBuildingChoiceRepresentation {
    if (preferences!.containsKey(KEY_EMPTY_CLASSROOM_LAST_BUILDING_CHOICE)) {
      return preferences!.getInt(KEY_EMPTY_CLASSROOM_LAST_BUILDING_CHOICE)!;
    }
    return 0;
  }

  set lastECBuildingChoiceRepresentation(int value) {
    preferences!.setInt(KEY_EMPTY_CLASSROOM_LAST_BUILDING_CHOICE, value);
    update();
  }

  String? get thisSemesterStartDate {
    if (preferences!.containsKey(KEY_THIS_SEMESTER_START_DATE)) {
      return preferences!.getString(KEY_THIS_SEMESTER_START_DATE)!;
    }
    return null;
  }

  set thisSemesterStartDate(String? value) {
    preferences!.setString(KEY_THIS_SEMESTER_START_DATE, value!);
    update();
  }

  TimeTableExtra? get semesterStartDates {
    if (preferences!.containsKey(KEY_SEMESTER_START_DATES)) {
      return TimeTableExtra.fromJson(
          jsonDecode(preferences!.getString(KEY_SEMESTER_START_DATES)!));
    }
    return null;
  }

  set semesterStartDates(TimeTableExtra? value) {
    preferences!.setString(KEY_SEMESTER_START_DATES, jsonEncode(value!));
    update();
  }

  /// User's preferences of Dashboard Widgets
  /// This getter always return a non-null value, defaults to default setting
  List<DashboardCard> get dashboardWidgetsSequence {
    if (preferences!.containsKey(KEY_DASHBOARD_WIDGETS)) {
      var rawCardList =
          (json.decode(preferences!.getString(KEY_DASHBOARD_WIDGETS)!) as List)
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
    }
    // [defaultDashboardCardList] is an immutable list, do not
    // return it directly!
    // Make a copy instead.
    return Constant.defaultDashboardCardList.toList();
  }

  set dashboardWidgetsSequence(List<DashboardCard>? value) {
    preferences!.setString(KEY_DASHBOARD_WIDGETS, jsonEncode(value));
    update();
  }

  List<Course> get manualAddedCourses {
    if (preferences!.containsKey(KEY_MANUALLY_ADDED_COURSE)) {
      var courseList =
          (json.decode(preferences!.getString(KEY_MANUALLY_ADDED_COURSE)!)
                  as List)
              .map((i) => Course.fromJson(i))
              .toList();

      return courseList;
    }
    return List<Course>.empty();
  }

  set manualAddedCourses(List<Course>? value) {
    if (value != null) {
      preferences!.setString(KEY_MANUALLY_ADDED_COURSE, jsonEncode(value));
    } else if (preferences!.containsKey(KEY_MANUALLY_ADDED_COURSE)) {
      preferences!.remove(KEY_MANUALLY_ADDED_COURSE);
    }
    update();
  }

  Campus get campus {
    if (preferences!.containsKey(KEY_PREFERRED_CAMPUS)) {
      String? value = preferences!.getString(KEY_PREFERRED_CAMPUS);
      return Constant.CAMPUS_VALUES
          .firstWhere((element) => element.toString() == value, orElse: () {
        campus = Campus.HANDAN_CAMPUS;
        return Campus.HANDAN_CAMPUS;
      });
    }
    return Campus.HANDAN_CAMPUS;
  }

  set campus(Campus campus) {
    preferences!.setString(KEY_PREFERRED_CAMPUS, campus.toString());
    update();
  }

  Language get defaultLanguage {
    Locale locale = PlatformDispatcher.instance.locale;
    if (locale.languageCode == 'en') {
      return Language.ENGLISH;
    } else if (locale.languageCode == 'ja') {
      return Language.JAPANESE;
    } else if (locale.languageCode == 'zh') {
      return Language.SIMPLE_CHINESE;
    } else {
      return Language.NONE;
    }
  }

  Language get language {
    if (preferences!.containsKey(KEY_PREFERRED_LANGUAGE)) {
      String? value = preferences!.getString(KEY_PREFERRED_LANGUAGE);
      return Constant.LANGUAGE_VALUES
          .firstWhere((element) => element.toString() == value, orElse: () {
        return defaultLanguage;
      });
    }
    return defaultLanguage;
  }

  set language(Language language) {
    preferences!.setString(KEY_PREFERRED_LANGUAGE, language.toString());
    update(['global']);
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

  // Token. If token is invalid, return null.
  JWToken? get fduholeToken {
    if (preferences!.containsKey(KEY_FDUHOLE_TOKEN)) {
      try {
        return JWToken.fromJsonWithVerification(
            jsonDecode(preferences!.getString(KEY_FDUHOLE_TOKEN)!));
      } catch (_) {}
    }
    return null;
  }

  set fduholeToken(JWToken? value) {
    if (value != null) {
      preferences!.setString(KEY_FDUHOLE_TOKEN, jsonEncode(value));
    } else {
      preferences!.remove(KEY_FDUHOLE_TOKEN);
    }
    update();
  }

  void deleteAllFduholeData() {
    preferences!.remove(KEY_FDUHOLE_TOKEN);
    //preferences!.remove(KEY_LAST_PUSH_TOKEN);
    preferences!.remove(KEY_FDUHOLE_FOLDBEHAVIOR);
    preferences!.remove(KEY_FDUHOLE_SORTORDER);
    preferences!.remove(KEY_HIDDEN_TREEHOLE);
    preferences!.remove(KEY_HIDDEN_TAGS);
  }

  //Debug Mode
  bool get debugMode {
    if (preferences!.containsKey(KEY_DEBUG_MODE)) {
      return preferences!.getBool(KEY_DEBUG_MODE)!;
    } else {
      return false;
    }
  }

  set debugMode(bool mode) {
    preferences!.setBool(KEY_DEBUG_MODE, mode);
    update();
  }

  //FDUHOLE Default Sorting Order
  SortOrder? get fduholeSortOrder {
    if (preferences!.containsKey(KEY_FDUHOLE_SORTORDER)) {
      String? str = preferences!.getString(KEY_FDUHOLE_SORTORDER);
      if (str == SortOrder.LAST_CREATED.getInternalString()) {
        return SortOrder.LAST_CREATED;
      } else if (str == SortOrder.LAST_REPLIED.getInternalString()) {
        return SortOrder.LAST_REPLIED;
      }
    }
    return null;
  }

  set fduholeSortOrder(SortOrder? value) {
    preferences!.setString(KEY_FDUHOLE_SORTORDER, value.getInternalString()!);
    update();
  }

  /// FDUHOLE Folded Post Behavior

  /// NOTE: This getter defaults to a FOLD and won't return [null]
  FoldBehavior get fduholeFoldBehavior {
    if (preferences!.containsKey(KEY_FDUHOLE_FOLDBEHAVIOR)) {
      int? savedPref = preferences!.getInt(KEY_FDUHOLE_FOLDBEHAVIOR);
      return FoldBehavior.values.firstWhere(
        (element) => element.index == savedPref,
        orElse: () => FoldBehavior.FOLD,
      );
    }
    return FoldBehavior.FOLD;
  }

  set fduholeFoldBehavior(FoldBehavior value) {
    preferences!.setInt(KEY_FDUHOLE_FOLDBEHAVIOR, value.index);
    update();
  }

  /// Clean Mode
  bool get cleanMode {
    if (preferences!.containsKey(KEY_CLEAN_MODE)) {
      return preferences!.getBool(KEY_CLEAN_MODE)!;
    } else {
      return false;
    }
  }

  set cleanMode(bool mode) {
    preferences!.setBool(KEY_CLEAN_MODE, mode);
    update(['hole']);
  }

  /// Hidden tags
  List<OTTag>? get hiddenTags {
    try {
      var json = jsonDecode(preferences!.getString(KEY_HIDDEN_TAGS)!);
      if (json is Iterable) {
        return json.map((e) => OTTag.fromJson(e)).toList();
      }
    } catch (ignored) {}
    return null;
  }

  set hiddenTags(List<OTTag>? tags) {
    if (tags == null) return;
    preferences!.setString(KEY_HIDDEN_TAGS, jsonEncode(tags));
    update();
  }

  /// Hide FDUHole
  bool get hideHole {
    if (preferences!.containsKey(KEY_HIDDEN_TREEHOLE)) {
      return preferences!.getBool(KEY_HIDDEN_TREEHOLE)!;
    } else {
      return false;
    }
  }

  set hideHole(bool mode) {
    preferences!.setBool(KEY_HIDDEN_TREEHOLE, mode);
    update();
  }

  /// Celebration words
  List<Celebration> get celebrationWords =>
      jsonDecode(preferences!.containsKey(KEY_CELEBRATION)
              ? preferences!.getString(KEY_CELEBRATION)!
              : Constant.SPECIAL_DAYS)
          .map<Celebration>((e) => Celebration.fromJson(e))
          .toList();

  set celebrationWords(List<Celebration> lists) {
    preferences!.setString(KEY_CELEBRATION, jsonEncode(lists));
    update();
  }

  /// Custom User Agent
  ///
  /// See:
  /// - [UserAgentInterceptor]
  /// - [BaseRepositoryWithDio]
  String? get customUserAgent {
    if (preferences!.containsKey(KEY_CUSTOM_USER_AGENT)) {
      return preferences!.getString(KEY_CUSTOM_USER_AGENT)!;
    }
    return null;
  }

  set customUserAgent(String? value) {
    if (value != null) {
      preferences!.setString(KEY_CUSTOM_USER_AGENT, value);
    } else {
      preferences!.remove(KEY_CUSTOM_USER_AGENT);
    }
    update();
  }

  /// Whether user has opted-in to banners
  bool get isBannerEnabled {
    if (preferences!.containsKey(KEY_BANNER_ENABLED)) {
      return preferences!.getBool(KEY_BANNER_ENABLED)!;
    }
    return true;
  }

  set isBannerEnabled(bool value) {
    preferences!.setBool(KEY_BANNER_ENABLED, value);
    update(['hole']);
  }

  bool get isTagSuggestionEnabled {
    if (preferences!.containsKey(KEY_TAG_SUGGESTIONS_ENABLE)) {
      return preferences!.getBool(KEY_TAG_SUGGESTIONS_ENABLE)!;
    }
    return false;
  }

  set isTagSuggestionEnabled(bool value) {
    preferences!.setBool(KEY_TAG_SUGGESTIONS_ENABLE, value);
    update(['hole']);
  }

  bool tagSuggestionAvailable = false;

  Future<bool> isTagSuggestionAvailable() async {
    return await getTagSuggestions('test') != null;
  }

  /// Primary color used by the app.
  int get primarySwatchV2 {
    if (preferences!.containsKey(KEY_PRIMARY_SWATCH_V2)) {
      int? color = preferences!.getInt(KEY_PRIMARY_SWATCH_V2);
      return Color(color!).value;
    }
    return Colors.blue.value;
  }

  /// Set primary swatch by color name defined in [Constant.TAG_COLOR_LIST].
  set primarySwatchV2(int value) {
    preferences!.setInt(KEY_PRIMARY_SWATCH_V2, Color(value).value);
    update(['global']);
  }

  int get lightWatermarkColor {
    if (preferences!.containsKey(KEY_LIGHT_WATERMARK_COLOR)) {
      int? color = preferences!.getInt(KEY_LIGHT_WATERMARK_COLOR);
      return Color(color!).value;
    }
    return 0x03000000;
  }

  set lightWatermarkColor(int value) {
    preferences!.setInt(KEY_LIGHT_WATERMARK_COLOR, Color(value).value);
    update();
  }

  int get darkWatermarkColor {
    if (preferences!.containsKey(KEY_DARK_WATERMARK_COLOR)) {
      int? color = preferences!.getInt(KEY_DARK_WATERMARK_COLOR);
      return Color(color!).value;
    }
    return 0x09000000;
  }

  set darkWatermarkColor(int value) {
    preferences!.setInt(KEY_DARK_WATERMARK_COLOR, Color(value).value);
    update();
  }

  bool get visibleWatermarkMode {
    if (preferences!.containsKey(KEY_VISIBLE_WATERMARK_MODE)) {
      return preferences!.getBool(KEY_VISIBLE_WATERMARK_MODE)!;
    } else {
      return false;
    }
  }

  set visibleWatermarkMode(bool mode) {
    preferences!.setBool(KEY_VISIBLE_WATERMARK_MODE, mode);
    update();
  }

  List<int> get hiddenHoles {
    if (preferences!.containsKey(KEY_HIDDEN_HOLES)) {
      return jsonDecode(preferences!.getString(KEY_HIDDEN_HOLES)!)
          .map<int>((e) => e as int)
          .toList();
    } else {
      return [];
    }
  }

  set hiddenHoles(List<int> list) {
    preferences!.setString(KEY_HIDDEN_HOLES, jsonEncode(list));
    update();
  }

  List<String> get hiddenNotifications {
    if (preferences!.containsKey(KEY_HIDDEN_NOTIFICATIONS)) {
      return jsonDecode(preferences!.getString(KEY_HIDDEN_NOTIFICATIONS)!)
          .map<String>((e) => e as String)
          .toList();
    } else {
      return [];
    }
  }

  set hiddenNotifications(List<String> list) {
    preferences!.setString(KEY_HIDDEN_NOTIFICATIONS, jsonEncode(list));
    update();
  }

  ThemeType get themeType {
    if (preferences!.containsKey(KEY_THEME_TYPE)) {
      return themeTypeFromInternalString(
              preferences!.getString(KEY_THEME_TYPE)) ??
          ThemeType.SYSTEM;
    } else {
      return ThemeType.SYSTEM;
    }
  }

  set themeType(ThemeType type) {
    preferences!.setString(KEY_THEME_TYPE, type.internalString());
    update(['global']);
  }

  bool get isMarkdownRenderingEnabled {
    if (preferences!.containsKey(KEY_MARKDOWN_ENABLED)) {
      return preferences!.getBool(KEY_MARKDOWN_ENABLED)!;
    }
    return true;
  }

  set isMarkdownRenderingEnabled(bool value) {
    preferences!.setBool(KEY_MARKDOWN_ENABLED, value);
    update();
  }
}

enum SortOrder { LAST_REPLIED, LAST_CREATED }

extension SortOrderEx on SortOrder? {
  String? displayTitle(BuildContext context) {
    switch (this) {
      case SortOrder.LAST_REPLIED:
        return S.of(context).last_replied;
      case SortOrder.LAST_CREATED:
        return S.of(context).last_created;
      case null:
        return null;
    }
  }

  String? getInternalString() {
    switch (this) {
      case SortOrder.LAST_REPLIED:
        return "time_updated";
      case SortOrder.LAST_CREATED:
        return "time_created";
      case null:
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

  String? internalString() {
    switch (this) {
      case FoldBehavior.FOLD:
        return 'fold';
      case FoldBehavior.HIDE:
        return 'hide';
      case FoldBehavior.SHOW:
        return 'show';
    }
  }
}

FoldBehavior foldBehaviorFromInternalString(String? str) {
  switch (str) {
    case 'fold':
      return FoldBehavior.FOLD;
    case 'hide':
      return FoldBehavior.HIDE;
    case 'show':
      return FoldBehavior.SHOW;
    default:
      return FoldBehavior.FOLD;
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
}

OTNotificationTypes? notificationTypeFromInternalString(String str) {
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

ThemeType? themeTypeFromInternalString(String? str) {
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
