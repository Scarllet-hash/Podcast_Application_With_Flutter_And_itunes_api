import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedStudyGraphic extends StatefulWidget {
  final Color primaryColor;
  final Color accentColor;

  const AnimatedStudyGraphic({
    Key? key,
    required this.primaryColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<AnimatedStudyGraphic> createState() => _AnimatedStudyGraphicState();
}

class _AnimatedStudyGraphicState extends State<AnimatedStudyGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;
  late Animation<double> _translate;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _translate = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacity = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle that pulses
              Opacity(
                opacity: _opacity.value * 0.3,
                child: Transform.scale(
                  scale: _scale.value * 0.8,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Middle circle that rotates
              Transform.rotate(
                angle: _rotation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.primaryColor.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                ),
              ),

              // Book icon
              Transform.translate(
                offset: Offset(0, _translate.value),
                child: Icon(
                  Icons.menu_book,
                  color: widget.primaryColor,
                  size: 40,
                ),
              ),

              // Orbiting elements
              ...List.generate(3, (index) {
                final angle = _rotation.value + (index * (2 * math.pi / 3));
                final radius = 50.0;
                final x = radius * math.cos(angle);
                final y = radius * math.sin(angle);

                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForIndex(index),
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.headphones;
      case 1:
        return Icons.lightbulb;
      case 2:
        return Icons.school;
      default:
        return Icons.star;
    }
  }
}
