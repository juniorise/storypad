import 'package:flutter/material.dart';
import 'package:write_story/colors/colors.dart';
import 'package:write_story/constants/config_constant.dart';
import 'package:write_story/widgets/w_icon_button.dart';

const double onPickingSwatchHeight =
    34 * 4 + ConfigConstant.margin2 * 2 + ConfigConstant.margin1 * 4;
const double onPickingColorHeight =
    34 * 2 + ConfigConstant.margin2 * 2 + ConfigConstant.margin1 * 2 - 4;

class WColorPicker extends StatefulWidget {
  const WColorPicker({
    Key? key,
    required this.onPickedColor,
    this.currentColor,
    required this.blackWhite,
  }) : super(key: key);

  final ValueChanged<Color> onPickedColor;
  final Color? currentColor;
  final ColorSwatch blackWhite;

  @override
  _WColorPickerState createState() => _WColorPickerState();
}

class _WColorPickerState extends State<WColorPicker> {
  Color? currentSelectedColor;
  Color? currentSelectedColorsSwatch;

  Map<int, List<int>>? _colorsMap;
  bool isColorChildPicking = false;

  List<ColorSwatch> _colorsSwatch = [];
  List<Color?> _colorNormal = [];

  @override
  void initState() {
    super.initState();
    _colorsSwatch.addAll(materialColors);
    _colorsSwatch.add(widget.blackWhite);
    _colorsMap = getColorMap(_colorsSwatch);

    materialColors.forEach((e) {
      if (_getMaterialColorShades(e).contains(widget.currentColor)) {
        currentSelectedColorsSwatch = e;
      }
    });
  }

  List<Color?> _getMaterialColorShades(ColorSwatch color) {
    return <Color?>[
      if (color[50] != null) color[50],
      if (color[100] != null) color[100],
      if (color[200] != null) color[200],
      if (color[300] != null) color[300],
      if (color[400] != null) color[400],
      if (color[500] != null) color[500],
      if (color[600] != null) color[600],
      if (color[700] != null) color[700],
      if (color[800] != null) color[800],
      if (color[900] != null) color[900],
    ];
  }

  Map<int, List<int>> getColorMap(List<dynamic> _colors) {
    /// final colorsMap = {
    ///   0: [0, 1, 2, 3],
    ///   1: [4, 5, 6, 7],
    ///   2: [8, 9, 10, 11],
    ///   3: [12, 13, 14, 15],
    ///   4: [16, 17, 18, 19],
    ///   5: [20]
    /// };
    ///
    Map<int, List<int>> colorsMap = {};
    final rowLength = 5;
    for (int c = 0; c <= _colors.length ~/ rowLength; c++) {
      List<int> children = [];
      for (int r = c; r < c + rowLength; r++) {
        int index = c * (rowLength - 1) + r;
        if (index <= _colors.length - 1) children.add(index);
      }
      colorsMap[c] = children;
    }
    return colorsMap;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: onPickingSwatchHeight,
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: ConfigConstant.fadeDuration,
        curve: Curves.easeInSine,
        padding: const EdgeInsets.all(ConfigConstant.margin2)
            .copyWith(bottom: ConfigConstant.margin2 - 8),
        height: !isColorChildPicking
            ? onPickingSwatchHeight
            : this._colorsMap!.length == 1
                ? onPickingColorHeight - 32 - 12
                : onPickingColorHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: ConfigConstant.circlarRadius2,
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            )
          ],
        ),
        child: buildColorListing(context),
      ),
    );
  }

  Column buildColorListing(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        this._colorsMap!.length,
        (c) {
          final childrenIndex = this._colorsMap![c];
          final List<Widget> children = List.generate(
            this._colorsMap![c]!.length,
            (i) {
              final int index = childrenIndex![i];
              final double right =
                  i != (childrenIndex.length) - 1 ? ConfigConstant.margin1 : 0;
              final dynamic? color;
              color = isColorChildPicking
                  ? _colorNormal[index]
                  : _colorsSwatch[index];

              final bool isSelected = widget.currentColor == color ||
                  currentSelectedColorsSwatch == color;
              return AnimatedContainer(
                duration: ConfigConstant.fadeDuration,
                margin: EdgeInsets.only(right: right, bottom: 0, top: 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2.0,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(isSelected ? 1 : 0),
                  ),
                ),
                child: WIconButton(
                  size: 32,
                  iconData: Icons.color_lens,
                  iconColor: color,
                  filledColor: color,
                  onPressed: () {
                    if (isColorChildPicking == false) {
                      setState(() {
                        isColorChildPicking = true;
                        _colorNormal = _getMaterialColorShades(color!);
                        _colorsMap = getColorMap(_colorNormal);
                      });
                    } else {
                      widget.onPickedColor(color);
                    }
                  },
                ),
              );
            },
          );

          final double bottom =
              this._colorsMap!.length - 1 == c ? 0 : ConfigConstant.margin1;
          return Container(
            margin: EdgeInsets.only(bottom: bottom),
            child: Row(children: children),
          );
        },
      ),
    );
  }
}