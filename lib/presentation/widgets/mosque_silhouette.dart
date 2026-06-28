import 'package:flutter/material.dart';

class MosqueSilhouette extends StatelessWidget {
  final Color color;

  const MosqueSilhouette({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: CustomPaint(
        painter: _MosquePainter(color: color),
      ),
    );
  }
}

class _MosquePainter extends CustomPainter {
  final Color color;

  _MosquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Bottom base
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    
    // Draw some simple abstract city/mosque domes and minarets
    // We'll draw them from right to left or left to right. Let's do left to right.
    
    path.lineTo(size.width, size.height * 0.7);
    
    // Right minaret
    path.lineTo(size.width * 0.9, size.height * 0.7);
    path.lineTo(size.width * 0.88, size.height * 0.3);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    path.lineTo(size.width * 0.82, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    
    // Right dome
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.4, size.width * 0.5, size.height * 0.7);
    
    // Center big dome
    path.lineTo(size.width * 0.45, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.35, size.height * 0.2, size.width * 0.25, size.height * 0.7);
    
    // Left minaret
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.18, size.height * 0.35);
    path.lineTo(size.width * 0.15, size.height * 0.25);
    path.lineTo(size.width * 0.12, size.height * 0.35);
    path.lineTo(size.width * 0.1, size.height * 0.7);
    
    // Left edge
    path.lineTo(0, size.height * 0.7);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MosquePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
