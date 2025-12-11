import 'package:flutter/material.dart';

class FlipClockDigit extends StatefulWidget {
  final String digit;

  const FlipClockDigit({Key? key, required this.digit}) : super(key: key);

  @override
  State<FlipClockDigit> createState() => _FlipClockDigitState();
}

class _FlipClockDigitState extends State<FlipClockDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _previousDigit;

  @override
  void initState() {
    super.initState();
    _previousDigit = widget.digit;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(FlipClockDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _previousDigit = oldWidget.digit;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isFirstHalf = _animation.value < 0.5;
        final currentDigit = isFirstHalf ? _previousDigit : widget.digit;
        final rotationAngle = _animation.value * 3.14159;

        // Responsive sizing
        final screenWidth = MediaQuery.of(context).size.width;
        final digitWidth = screenWidth < 400 ? 38.0 : 50.0;
        final digitHeight = screenWidth < 400 ? 52.0 : 70.0;
        final fontSize = screenWidth < 400 ? 30.0 : 40.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(isFirstHalf ? rotationAngle : 3.14159 - rotationAngle),
          child: Container(
            width: digitWidth,
            height: digitHeight,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                currentDigit ?? '0',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
