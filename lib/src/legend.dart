import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  const Legend({
    required this.title,
    required this.color,
    required this.style,
    required this.legendShape,
    Key? key,
    this.onTap,
  }) : super(key: key);

  final String title;
  final Color color;
  final TextStyle style;
  final BoxShape legendShape;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
            height: 20.0,
            width: 18.0,
            decoration: BoxDecoration(
              shape: legendShape,
              color: color,
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              title,
              style: style,
              softWrap: true,
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }
}
