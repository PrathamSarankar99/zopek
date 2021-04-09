import 'package:flutter/material.dart';

class BlinkingButton extends StatefulWidget {
  @override
  _BlinkingButtonState createState() => _BlinkingButtonState();
}

class _BlinkingButtonState extends State<BlinkingButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 600));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
