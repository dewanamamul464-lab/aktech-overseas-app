import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double? fontSize;   // optional font size
  final Color? color;       // optional text color

  const SectionHeader({
    Key? key,
    required this.title,
    this.fontSize,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 18,          // default size 18
          fontWeight: FontWeight.bold,
          color: color ?? Colors.black87,    // default dark text
        ),
      ),
    );
  }
}
