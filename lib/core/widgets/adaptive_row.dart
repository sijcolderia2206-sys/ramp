import 'package:flutter/material.dart';

class AdaptiveRow extends StatelessWidget {
  const AdaptiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.gap,
    this.wrap = false,
  });

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final VerticalDirection verticalDirection;
  final TextDirection? textDirection;
  final double? gap;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final rowChildren = _withSpacing(children, gap);

    if (wrap) {
      return Wrap(
        alignment: _wrapAlignment(mainAxisAlignment),
        crossAxisAlignment: _wrapCrossAlignment(crossAxisAlignment),
        direction: Axis.horizontal,
        runSpacing: gap ?? 0,
        spacing: gap ?? 0,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      verticalDirection: verticalDirection,
      textDirection: textDirection,
      children: rowChildren,
    );
  }

  List<Widget> _withSpacing(List<Widget> items, double? spacing) {
    if (spacing == null || items.length < 2) {
      return items;
    }

    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        spaced.add(SizedBox(width: spacing));
      }
      spaced.add(items[i]);
    }
    return spaced;
  }

  WrapAlignment _wrapAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.start;
    }
  }

  WrapCrossAlignment _wrapCrossAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        return WrapCrossAlignment.start;
    }
  }
}
