import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import 'chart_painter.dart';
import 'legend.dart';
import 'utils.dart';

enum LegendPosition { top, bottom, left, right }

enum ChartType { disc, ring }

typedef ChartValueLabelFormatter<T> = String Function(T value);

class PieChart<T> extends StatefulWidget {
  const PieChart({
    required this.dataMap,
    this.labelFormatter,
    this.chartType = ChartType.disc,
    this.chartRadius,
    this.animationDuration,
    this.chartLegendSpacing = 48,
    this.colorList = defaultColorList,
    this.initialAngleInDegree,
    this.formatChartValues,
    this.centerText,
    this.centerTextStyle,
    this.ringStrokeWidth = 20.0,
    this.legendOptions = const LegendOptions(),
    this.chartValuesOptions = const ChartValuesOptions(),
    this.emptyColor = Colors.grey,
    this.gradientList,
    this.emptyColorGradient = const [Colors.black26, Colors.black54],
    Key? key,
    this.degreeOptions = const DegreeOptions(),
    this.baseChartColor = Colors.transparent,
    this.totalValue,
    this.onLabelPressed,
    this.nullValueFormatter,
  }) : super(key: key);

  final Map<T?, double> dataMap;

  /// [labelFormatter] is used to format the label of the chart values.
  final ChartValueLabelFormatter<T>? labelFormatter;
  final ChartType chartType;

  /// [nullValueFormatter] is the text that will be displayed when the value of the chart is null.
  /// By default it is set to 'Others'.
  final String? nullValueFormatter;
  final double? chartRadius;
  final Duration? animationDuration;
  final double chartLegendSpacing;
  final List<Color> colorList;
  final List<List<Color>>? gradientList;
  @Deprecated('use degreeOptions. instead')
  final double? initialAngleInDegree;
  final Function? formatChartValues;
  final String? centerText;
  final TextStyle? centerTextStyle;
  final double ringStrokeWidth;
  final LegendOptions legendOptions;
  final ChartValuesOptions chartValuesOptions;
  final Color emptyColor;
  final List<Color> emptyColorGradient;
  final DegreeOptions degreeOptions;
  final Color baseChartColor;
  final double? totalValue;
  final void Function(T data)? onLabelPressed;

  @override
  // ignore: library_private_types_in_public_api
  _PieChartState<T> createState() => _PieChartState<T>();
}

class _PieChartState<T> extends State<PieChart<T>>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  AnimationController? controller;
  double _animFraction = 0.0;

  List<String>? legendTitles;

  late List<double> legendValues;
  late List<T?> data;

  String _format(T? data) {
    if (data == null) {
      return widget.nullValueFormatter ?? 'Others';
    }
    return widget.labelFormatter?.call(data) ?? data.toString();
  }

  void initLegends() {
    data = widget.dataMap.keys.toList();
    legendTitles = data.map((e) => _format(e)).toList(growable: false);
  }

  void initValues() {
    legendValues = widget.dataMap.values.toList(growable: false);
  }

  void initData() {
    assert(
      widget.dataMap.isNotEmpty,
      "dataMap passed to pie chart cant be null or empty",
    );
    initLegends();
    initValues();
  }

  @override
  void initState() {
    super.initState();
    initData();
    controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 800),
      vsync: this,
    );
    final Animation curve = CurvedAnimation(
      parent: controller!,
      curve: Curves.decelerate,
    );
    animation =
        Tween<double>(begin: 0, end: 1).animate(curve as Animation<double>)
          ..addListener(() {
            setState(() {
              _animFraction = animation.value;
            });
          });
    controller!.forward();
  }

  Widget _getChart() {
    return Flexible(
      child: LayoutBuilder(
        builder: (_, c) => SizedBox(
          height: widget.chartRadius != null
              ? c.maxWidth < widget.chartRadius!
                  ? c.maxWidth
                  : widget.chartRadius
              : null,
          child: CustomPaint(
            painter: PieChartPainter(
                _animFraction,
                widget.chartValuesOptions.showChartValues,
                widget.chartValuesOptions.showChartValuesOutside,
                widget.colorList,
                chartValueStyle: widget.chartValuesOptions.chartValueStyle,
                chartValueBackgroundColor:
                    widget.chartValuesOptions.chartValueBackgroundColor,
                values: legendValues,
                titles: legendTitles,
                showValuesInPercentage:
                    widget.chartValuesOptions.showChartValuesInPercentage,
                decimalPlaces: widget.chartValuesOptions.decimalPlaces,
                showChartValueLabel:
                    widget.chartValuesOptions.showChartValueBackground,
                chartType: widget.chartType,
                centerText: widget.centerText,
                centerTextStyle: widget.centerTextStyle,
                formatChartValues: widget.formatChartValues,
                strokeWidth: widget.ringStrokeWidth,
                emptyColor: widget.emptyColor,
                gradientList: widget.gradientList,
                emptyColorGradient: widget.emptyColorGradient,
                degreeOptions: widget.degreeOptions.copyWith(
                  // because we've deprecated initialAngleInDegree,
                  // we want the old value to be used if it's not null
                  // ignore: deprecated_member_use_from_same_package
                  initialAngle: widget.initialAngleInDegree,
                ),
                baseChartColor: widget.baseChartColor,
                totalValue: widget.totalValue),
            child: const AspectRatio(aspectRatio: 1),
          ),
        ),
      ),
    );
  }

  Widget _getPieChart() {
    switch (widget.legendOptions.legendPosition) {
      case LegendPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getLegend(
              padding: EdgeInsets.only(
                bottom: widget.chartLegendSpacing,
              ),
            ),
            _getChart(),
          ],
        );

      case LegendPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getChart(),
            _getLegend(
              padding: EdgeInsets.only(
                top: widget.chartLegendSpacing,
              ),
            ),
          ],
        );
      case LegendPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getLegend(
              padding: EdgeInsets.only(
                right: widget.chartLegendSpacing,
              ),
            ),
            _getChart(),
          ],
        );
      case LegendPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getChart(),
            _getLegend(
              padding: EdgeInsets.only(
                left: widget.chartLegendSpacing,
              ),
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getChart(),
            _getLegend(
              padding: EdgeInsets.only(
                left: widget.chartLegendSpacing,
              ),
            ),
          ],
        );
    }
  }

  Widget _getLegend({EdgeInsets? padding}) {
    if (widget.legendOptions.showLegends) {
      final isGradientPresent = widget.gradientList?.isNotEmpty ?? false;
      final isNonGradientElementPresent =
          (widget.dataMap.length - (widget.gradientList?.length ?? 0)) > 0;
      return Padding(
        padding: padding!,
        child: Wrap(
          direction: widget.legendOptions.showLegendsInRow
              ? Axis.horizontal
              : Axis.vertical,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (int i = 0; i < legendTitles!.length; i++)
              () {
                final item = legendTitles![i];
                final d = data[i];
                return Legend(
                  title: item,
                  onTap: d != null
                      ? () {
                          widget.onLabelPressed?.call(d);
                        }
                      : null,
                  color: isGradientPresent
                      ? getGradient(
                          widget.gradientList!, legendTitles!.indexOf(item),
                          isNonGradientElementPresent:
                              isNonGradientElementPresent,
                          emptyColorGradient: widget.emptyColorGradient)[0]
                      : getColor(
                          widget.colorList,
                          legendTitles!.indexOf(item),
                        ),
                  style: widget.legendOptions.legendTextStyle,
                  legendShape: widget.legendOptions.legendShape,
                );
              }()
          ],
        ),
      );
    } else {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: _getPieChart(),
    );
  }

  @override
  void didUpdateWidget(PieChart<T> oldWidget) {
    initData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
