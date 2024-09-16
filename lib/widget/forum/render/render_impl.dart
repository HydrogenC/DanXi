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

import 'package:dan_xi/repository/forum/forum_repository.dart';
import 'package:dan_xi/util/platform_universal.dart';
import 'package:dan_xi/util/stickers.dart';
import 'package:dan_xi/util/viewport_utils.dart';
import 'package:dan_xi/widget/forum/auto_bbs_image.dart';
import 'package:dan_xi/widget/forum/forum_widgets.dart';
import 'package:dan_xi/widget/forum/render/base_render.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:nil/nil.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:win32/win32.dart';

const double kFontSize = 16.0;
const double kFontLargerSize = 24.0;
/*BaseRender kHtmlRender = (BuildContext context, String? content,
    ImageTapCallback? onTapImage, LinkTapCallback? onTapLink) {
  double imageWidth = ViewportUtils.getMainNavigatorWidth(context) * 0.75;
  Style noPaddingStyle = Style(
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    fontSize: FontSize(kFontSize),
  );
  return Html(
    shrinkWrap: true,
    data: content,
    style: {
      "body": noPaddingStyle,
      "p": noPaddingStyle,
    },
    onLinkTap: (url, _, __, ___) => onTapLink?.call(url),
    customImageRenders: {
      networkSourceMatcher(): (context, attributes, element) {
        return Center(
          child: AutoBBSImage(
              src: attributes['src'],
              maxWidth: imageWidth,
              onTapImage: onTapImage),
        );
      },
    },
  );
};*/

MarkdownConfig _createMarkdownConfig(BuildContext context,
    {ImgBuilder? imageBuilder, void Function(String)? onTapLink}) {
  final baseConfig = Theme.of(context).brightness == Brightness.dark
      ? MarkdownConfig.darkConfig
      : MarkdownConfig.defaultConfig;
  return baseConfig.copy(configs: [
    const H1Config(style: TextStyle(fontSize: kFontLargerSize, fontWeight: FontWeight.normal)),
    LinkConfig(
        onTap: onTapLink,
        style: const TextStyle(color: Color(0xff0969da), decoration: null)),
    if (imageBuilder != null) ImgConfig(builder: imageBuilder),
  ]);
}

// Override the font size and background of blockquote
MarkdownConfig _markdownConfigOverride(
    MarkdownConfig config, double? fontSize) {
  return config.copy(configs: [
    PConfig(textStyle: TextStyle(fontSize: fontSize)),
    LinkConfig(
        onTap: config.a.onTap,
        style: config.a.style.copyWith(fontSize: fontSize)),
  ]);
}

/// Markdown render creator.
///
/// [defaultFontSize] is the default font size of the markdown content. If it is
/// null, the default font size of theme will be used.
final kMarkdownRenderFactory = (double? defaultFontSize) =>
    (BuildContext context,
        String? content,
        ImageTapCallback? onTapImage,
        LinkTapCallback? onTapLink,
        bool translucentCard,
        bool isPreviewWidget) {
      double imageWidth = ViewportUtils.getMainNavigatorWidth(context) * 0.75;
      ImgBuilder imageBuilder = (uri, attr) {
        String url = uri.toString();
        // render stickers first
        if (url.startsWith("danxi_")) {
          // backward compatibility: <=1.4.3, danxi_ is used; after that, dx_ is used
          url = url.replaceFirst("danxi_", "dx_");
        }
        if (url.startsWith("dx_")) {
          var asset = getStickerAssetPath(url);
          // print(asset);
          if (asset != null) {
            return Image.asset(
              asset,
              width: 50,
              height: 50,
            );
          }
        }

        return Center(
          child: AutoBBSImage(
              key: UniqueKey(),
              src: url,
              maxWidth: imageWidth,
              onTapImage: onTapImage),
        );
      };

      return MarkdownBlock(
        selectable: false,
        data: content!,
        config: _markdownConfigOverride(
            _createMarkdownConfig(context,
                imageBuilder: imageBuilder, onTapLink: onTapLink),
            defaultFontSize),
        generator: MarkdownGenerator(inlineSyntaxList: [
          LatexInlineSyntax(),
          LatexMultiLineSyntax(),
          MentionSyntax()
        ], generators: [
          inlineLatexGenerator,
          multiLineLatexGenerator,
          floorMentionGenerator(translucentCard, isPreviewWidget),
          holeMentionGenerator(translucentCard, isPreviewWidget)
        ]),
      );
    };

final BaseRender kMarkdownRender = kMarkdownRenderFactory(kFontSize);

final BaseRender kMarkdownSelectorRender = (BuildContext context,
    String? content,
    ImageTapCallback? onTapImage,
    LinkTapCallback? onTapLink,
    bool translucentCard,
    bool isPreviewWidget) {
  return MarkdownWidget(
    data: content!,
    selectable: true,
    config: _markdownConfigOverride(
        _createMarkdownConfig(context, onTapLink: onTapLink), kFontLargerSize),
  );
};

final BaseRender kPlainRender = (BuildContext context,
    String? content,
    ImageTapCallback? onTapImage,
    LinkTapCallback? onTapLink,
    bool translucentCard,
    bool isPreviewWidget) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(content ?? "")],
  );
};

SpanNodeGeneratorWithTag inlineLatexGenerator = SpanNodeGeneratorWithTag(
    tag: LatexInlineSyntax.tag,
    generator: (e, config, visitor) => MarkdownInlineLatexNode(e));

SpanNodeGeneratorWithTag multiLineLatexGenerator = SpanNodeGeneratorWithTag(
    tag: LatexMultiLineSyntax.tag,
    generator: (e, config, visitor) => MarkdownMultiLineLatexNode(e));

SpanNodeGeneratorWithTag holeMentionGenerator(
        hasBackgroundImage, isPreviewWidget) =>
    SpanNodeGeneratorWithTag(
        tag: MentionSyntax.holeTag,
        generator: (e, config, visitor) =>
            MarkdownHoleMentionNode(e, hasBackgroundImage, isPreviewWidget));

SpanNodeGeneratorWithTag floorMentionGenerator(
        hasBackgroundImage, isPreviewWidget) =>
    SpanNodeGeneratorWithTag(
        tag: MentionSyntax.floorTag,
        generator: (e, config, visitor) =>
            MarkdownFloorMentionNode(e, hasBackgroundImage, isPreviewWidget));

Widget _buildLatexWidget(String content) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Math.tex(content),
  );
}

WidgetSpan _toWidgetSpan(Widget widget) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: widget,
  );
}

class MarkdownInlineLatexNode extends SpanNode {
  final md.Element element;
  MarkdownInlineLatexNode(this.element);

  @override
  InlineSpan build() {
    return _toWidgetSpan(_buildLatexWidget(element.textContent));
  }
}

class MarkdownMultiLineLatexNode extends SpanNode {
  final md.Element element;
  MarkdownMultiLineLatexNode(this.element);

  @override
  InlineSpan build() {
    // Reference: https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart
    return _toWidgetSpan(
      Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: _buildLatexWidget(element.textContent)),
      ),
    );
  }
}

class MarkdownFloorMentionNode extends SpanNode {
  final bool hasBackgroundImage;
  final bool isPreviewWidget;
  final md.Element element;

  MarkdownFloorMentionNode(
      this.element, this.hasBackgroundImage, this.isPreviewWidget);

  @override
  InlineSpan build() {
    if (isPreviewWidget) {
      return _toWidgetSpan(OTMentionPreviewWidget(
        id: int.parse(element.textContent),
        type: OTMentionType.FLOOR,
        hasBackgroundImage: hasBackgroundImage,
      ));
    } else {
      return _toWidgetSpan(OTFloorMentionWidget(
        future: ForumRepository.getInstance()
            .loadSpecificFloor(int.parse(element.textContent)),
        hasBackgroundImage: hasBackgroundImage,
      ));
    }
  }
}

class MarkdownHoleMentionNode extends SpanNode {
  final bool hasBackgroundImage;
  final bool isPreviewWidget;
  final md.Element element;

  MarkdownHoleMentionNode(
      this.element, this.hasBackgroundImage, this.isPreviewWidget);

  @override
  InlineSpan build() {
    if (isPreviewWidget) {
      return _toWidgetSpan(OTMentionPreviewWidget(
        id: int.parse(element.textContent),
        type: OTMentionType.HOLE,
        hasBackgroundImage: hasBackgroundImage,
      ));
    } else {
      return _toWidgetSpan(OTFloorMentionWidget(
        future: ForumRepository.getInstance()
            .loadSpecificHole(int.parse(element.textContent))
            .then((value) => value?.floors?.first_floor),
        hasBackgroundImage: hasBackgroundImage,
      ));
    }
  }
}

class LatexInlineSyntax extends md.InlineSyntax {
  static const String tag = "tex";
  LatexInlineSyntax() : super(r'(?<!\$)\$([^\$]+?)\$(?!\$)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var tex = match[1]!;
    parser.addNode(md.Element.text(tag, tex));
    return true;
  }
}

class LatexMultiLineSyntax extends md.InlineSyntax {
  static const String tag = "texMultiLine";
  LatexMultiLineSyntax() : super(r'\$\$([^\$]*?)\$\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var tex = match[1]!;
    parser.addNode(md.Element.text(tag, tex));
    return true;
  }
}

class MentionSyntax extends md.InlineSyntax {
  static const String holeTag = "holeMention";
  static const String floorTag = "floorMention";
  MentionSyntax() : super(r'(#{1,2})([0-9]+)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final type = match[1]!;
    final mention = match[2]!;
    if (type == "#") {
      parser.addNode(md.Element.text(holeTag, mention));
      return true;
    } else if (type == "##") {
      parser.addNode(md.Element.text(floorTag, mention));
      return true;
    }
    return false;
  }
}

class AuditSyntax extends md.InlineSyntax {
  static const String tag = "mark";
  AuditSyntax() : super(r'<audit>([^\$]*?)</audit>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var sensitiveString = match[1]!;
    parser.addNode(md.Element.text(tag, sensitiveString));
    return true;
  }
}
