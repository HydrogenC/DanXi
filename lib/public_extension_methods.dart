/*
 *     Copyright (C) 2021  w568w
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

import 'package:dan_xi/common/constant.dart';
import 'package:flutter/widgets.dart';

extension StringEx on String {
  String between(String a, String b, {bool headGreedy = true}) {
    if (indexOf(a) < 0) return null;
    if (headGreedy) {
      if (indexOf(b, indexOf(a) + a.length) < 0) return null;
      return substring(
          indexOf(a) + a.length, indexOf(b, indexOf(a) + a.length));
    } else {
      if (indexOf(b, lastIndexOf(a) + a.length) < 0) return null;
      return substring(
          lastIndexOf(a) + a.length, indexOf(b, lastIndexOf(a) + a.length));
    }
  }
}

extension ObjectEx on dynamic {
  void fire() {
    Constant.eventBus.fire(this);
  }
}

extension StateEx on State {
  void refreshSelf() {
    // ignore: invalid_use_of_protected_member
    setState(() {});
  }
}

extension MapEx on Map {
  String encodeMap() {
    return keys.map((key) {
      var k = key.toString();
      var v = Uri.encodeComponent(this[key].toString());
      return '$k=$v';
    }).join('&');
  }
}
