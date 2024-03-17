/*
 *     Copyright (C) 2022  DanXi-Dev
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

import 'package:dan_xi/feature/base_feature.dart';
import 'package:dan_xi/page/subpage_dashboard.dart';
import 'package:dan_xi/provider/settings_provider.dart';
import 'package:get/get.dart';

/// Hold a list of notification shown in [HomeSubpage].
class NotificationProvider {
  final RxList<Feature> _notifications = RxList<Feature>([]);

  RxList<Feature> get notifications => _notifications;

  void addNotification(Feature feature) {
    if (_notifications.any((element) =>
        element.runtimeType.toString() == feature.runtimeType.toString())) {
      return;
    }
    if (SettingsController.getInstance()
        .hiddenNotifications
        .contains(feature.runtimeType.toString())) return;

    _notifications.add(feature);
  }

  void removeNotification(Feature feature) {
    _notifications.removeWhere((element) {
      final equality =
          feature.runtimeType.toString() == element.runtimeType.toString();
      return equality;
    });
  }
}
