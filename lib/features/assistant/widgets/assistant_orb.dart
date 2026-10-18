import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/services/speech_service.dart';
import '../../../core/theme/cyber_colors.dart';

class AssistantOrb extends StatefulWidget {
  final AssistantState state;
  final double size;
  final bool reducedMotion;

  const AssistantOrb({
    super.key,
    required this.state,
    this.size = 120.0,
    this.reducedMotion = false,
  });

  @override
  State<AssistantOrb> createState() => _AssistantOrbState();
}

class _AssistantOrbState extends State<AssistantOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (!widget.reducedMotion) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AssistantOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = CyberColors.primaryCyan;
    Color secondaryColor = CyberColors.neonViolet;

    switch (widget.state) {
      case AssistantState.idle:
        primaryColor = CyberColors.primaryCyan;
        secondaryColor = CyberColors.neonViolet;
        break;
      case AssistantState.listening:
        primaryColor = CyberColors.primaryCyan;
        secondaryColor = CyberColors.electricBlue;
        break;
      case AssistantState.processing:
        primaryColor = CyberColors.neonViolet;
        secondaryColor = CyberColors.cyberPink;
        break;
      case AssistantState.speaking:
        primaryColor = CyberColors.matrixGreen;
        secondaryColor = CyberColors.primaryCyan;
        break;
      case AssistantState.error:
        primaryColor = CyberColors.cyberRed;
        secondaryColor = CyberColors.cyberAmber;
        break;
    }

    if (widget.reducedMotion) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              primaryColor,
              secondaryColor.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Center(
          child: Icon(Icons.bolt, color: primaryColor, size: widget.size * 0.4),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _OrbPainter(
            progress: progress,
            state: widget.state,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final AssistantState state;
  final Color primaryColor;
  final Color secondaryColor;

  _OrbPainter({
    required this.progress,
    required this.state,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.35),
          secondaryColor.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));

    canvas.drawCircle(center, radius * 1.3, glowPaint);

    // Inner core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.8), primaryColor, secondaryColor],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.7));

    final pulse = 0.85 + 0.15 * math.sin(progress * 2 * math.pi);
    canvas.drawCircle(center, radius * 0.55 * pulse, corePaint);

    // Concentric orbiting rings
    final ringPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final angle = progress * 2 * math.pi;
    final rx = radius * 0.85;
    final ry = radius * 0.35;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      ringPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-angle * 1.4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: ry * 2, height: rx * 2),
      ringPaint..color = secondaryColor.withOpacity(0.5),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.state != state ||
        oldDelegate.primaryColor != primaryColor;
  }
}
