import 'package:flutter/material.dart';

class BaseButton extends StatefulWidget {
  final String textButton;
  final Color buttonColor;
  final Color textColor;
  ValueSetter<bool> onPressed;

  BaseButton(
      {required this.textButton,
      required this.buttonColor,
      required this.textColor,
      required this.onPressed});

  @override
  _BaseButtonState createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  RaisedButton _raisedButton() {
    return RaisedButton(
      color: widget.buttonColor,
      textColor: widget.textColor,
      onPressed: () {
        widget.onPressed(true);
      },
      child: Text(widget.textButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _raisedButton();
  }
}
