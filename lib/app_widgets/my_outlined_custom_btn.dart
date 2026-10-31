import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/util_helper.dart';

class MyOutlinedCustomBtn extends StatelessWidget{
  VoidCallback? onPressed;
  String title;
  double? mWidth;

  MyOutlinedCustomBtn({
    required this.title,
    required this.onPressed,
    this.mWidth = 140
});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: mWidth,
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Colors.blue
            )
          ),
          child: Text(title, style: mTextStyle16(),)
      ),
    );
  }
}