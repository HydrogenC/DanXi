/*
 *     Copyright (C) 2021 kavinzhao
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

import 'package:dan_xi/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class BBSEditor {

  static Future<void> createNewPost(BuildContext context) async {
    //TODO: tag editor
    String content = await _showEditor(context);
    //TODO: POST to server
    // Obtain token form postRepository

    //TODO: handle failure
  }

  static Future<void> createNewReply(BuildContext context, num discussionId, num postId) async {
    //TODO: tag editor
    String content = await _showEditor(context);
    //TODO: POST to server
    // Note: postId refers to the specific post the user is replying to, can be NULL

    //TODO: handle failure
  }

  static Future<void> reportPost(BuildContext context, num postId) async {
    //TODO: tag editor
    String content = await _showEditor(context);
    //TODO: POST to server

    //TODO: handle failure
  }

  static Future<String> _showEditor(BuildContext context) async {
    HtmlEditorController _controller = HtmlEditorController();
    await showPlatformDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("TODO: post"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 300,
                width: MediaQuery.of(context).size.width - 50,
                child: HtmlEditor(
                  controller: _controller, //required
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: "Your text here...",
                    //initalText: "text content initial, if any",
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                      defaultToolbarButtons: [
                        //add constructors here and set buttons to false, e.g.
                        StyleButtons(),
                        FontSettingButtons(),
                        FontButtons(),
                        ColorButtons(),
                        ListButtons(),
                        ParagraphButtons(lineHeight: false, caseConverter: false),
                        InsertButtons(),
                        OtherButtons(),
                      ]
                  ),
                  otherOptions: OtherOptions(
                    height: MediaQuery.of(context).size.height - 500,
                  ),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                  return null;
                }),
            TextButton(
                child: Text("TODO: finished editing"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        )
    );
    return await _controller.getText();
  }
}