import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmallImg extends StatelessWidget {
  final String url;

  const SmallImg({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: 30,
      width: 30,
      fit: BoxFit.cover,
    );
  }
}
