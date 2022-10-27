import 'package:flutter/material.dart';

class CircularIndicator extends StatelessWidget {
  final double size;
  final Color color;
  const CircularIndicator({Key? key, required this.size, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(color: color),
      ),
    );
  }
}
