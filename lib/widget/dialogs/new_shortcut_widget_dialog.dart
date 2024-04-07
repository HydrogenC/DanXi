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

import 'package:dan_xi/common/constant.dart';
import 'package:dan_xi/generated/l10n.dart';
import 'package:dan_xi/model/dashboard_card.dart';
import 'package:dan_xi/provider/settings_provider.dart';
import 'package:dan_xi/util/platform_universal.dart';
import 'package:dan_xi/util/public_extension_methods.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Allows user to create custom dashboard widgets that link to certain websites.
class NewShortcutDialog extends StatefulWidget {
  const NewShortcutDialog({super.key});

  @override
  NewShortcutDialogState createState() => NewShortcutDialogState();
}

class NewShortcutDialogState extends State<NewShortcutDialog> {
  final TextEditingController _nameTextFieldController =
      TextEditingController();
  final TextEditingController _linkTextFieldController =
      TextEditingController();
  String _errorText = "";

  void _save() async {
    if (!_linkTextFieldController.text.startsWith('http')) {
      _linkTextFieldController.text = 'http://${_linkTextFieldController.text}';
    }
    // Validate URL
    try {
      await Dio().head(_linkTextFieldController.text);
      SettingsProvider.getInstance().set(
          SettingsProvider.dashboardWidgetsSequence,
          SettingsProvider.getInstance()
              .get(SettingsProvider.dashboardWidgetsSequence)
              .followedBy([
            DashboardCard(
                Constant.FEATURE_CUSTOM_CARD,
                _nameTextFieldController.text,
                _linkTextFieldController.text,
                true)
          ]).toList());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _errorText = S.of(context).unable_to_access_url;
      refreshSelf();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).new_shortcut_card),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.of(context).new_shortcut_description),
          Text(
            _errorText,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
          if (PlatformX.isCupertino(context))
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 0, 4),
                child: Text(S.of(context).name),
              ),
            ),
          TextField(
            controller: _nameTextFieldController,
            decoration: InputDecoration(
              labelText: S.of(context).name,
              icon: PlatformX.isMaterial(context)
                  ? const Icon(Icons.lock_outline)
                  : const Icon(CupertinoIcons.lock_circle),
            ),
          ),
          if (PlatformX.isCupertino(context))
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 0, 4),
                child: Text(S.of(context).link),
              ),
            ),
          TextField(
            controller: _linkTextFieldController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: S.of(context).link,
              icon: PlatformX.isMaterial(context)
                  ? const Icon(Icons.lock_outline)
                  : const Icon(CupertinoIcons.lock_circle),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        TextButton(
          child: Text(S.of(context).add),
          onPressed: () {
            _save();
          },
        )
      ],
    );
  }
}
