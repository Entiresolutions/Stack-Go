import 'package:flutter/material.dart';

/// Centralized renderer for authentic 3D Isometric Slabs
class IsometricSlabRenderer {
  /// Isometric tilt ratio (angle ~15.6 degrees) ensuring realistic 3D isometric projection
  static const double tiltSlope = 0.28;

  /// Renders a complete 3D isometric slab with 3 distinct faces:
  /// - Top Face: Bright, illuminated diamond surface
  /// - Left Face: Darker shaded shadow face
  /// - Right Face: Medium half-tone diffuse face
  static void renderSlab({
    required Canvas canvas,
    required double width,
    required double height,
    required Color baseColor,
    int blockIndex = 0,
    double opacity = 1.0,
    bool isCentered = false,
    double offsetX = 0.0,
    double offsetY = 0.0,
  }) {
    if (width <= 0.0 || height <= 0.0 || opacity <= 0.0) return;

    final hasOffset = offsetX != 0.0 || offsetY != 0.0;
    if (hasOffset) {
      canvas.save();
      canvas.translate(offsetX, offsetY);
    }

    final double tilt = (width / 2) * tiltSlope;

    // 1. Calculate 3D Vertex Coordinates
    final double xLeft = isCentered ? -width / 2 : 0.0;
    final double xRight = isCentered ? width / 2 : width;
    final double xCenter = isCentered ? 0.0 : width / 2;
    final double yMid = isCentered ? -height / 2 : 0.0;
    final double yBot = isCentered ? height / 2 : height;

    final vBack = Offset(xCenter, yMid - tilt);
    final vLeft = Offset(xLeft, yMid);
    final vRight = Offset(xRight, yMid);
    final vFront = Offset(xCenter, yMid + tilt);

    final vLeftBot = Offset(xLeft, yBot);
    final vFrontBot = Offset(xCenter, yBot + tilt);
    final vRightBot = Offset(xRight, yBot);

    // 2. LEFT FACE (Shaded darker - shadow side)
    final leftFacePath = Path()
      ..moveTo(vLeft.dx, vLeft.dy)
      ..lineTo(vFront.dx, vFront.dy)
      ..lineTo(vFrontBot.dx, vFrontBot.dy)
      ..lineTo(vLeftBot.dx, vLeftBot.dy)
      ..close();

    final leftBaseColor =
        Color.lerp(baseColor, const Color(0xFF0A0F1A), 0.38)!;
    final leftGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(leftBaseColor, Colors.white, 0.06)!
            .withValues(alpha: opacity),
        Color.lerp(leftBaseColor, Colors.black, 0.28)!
            .withValues(alpha: opacity),
      ],
    );

    final leftPaint = Paint()
      ..shader = leftGradient.createShader(leftFacePath.getBounds())
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftFacePath, leftPaint);

    // 3. RIGHT FACE (Medium shade - half-tone side)
    final rightFacePath = Path()
      ..moveTo(vFront.dx, vFront.dy)
      ..lineTo(vRight.dx, vRight.dy)
      ..lineTo(vRightBot.dx, vRightBot.dy)
      ..lineTo(vFrontBot.dx, vFrontBot.dy)
      ..close();

    final rightBaseColor =
        Color.lerp(baseColor, const Color(0xFF141F30), 0.16)!;
    final rightGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(rightBaseColor, Colors.white, 0.14)!
            .withValues(alpha: opacity),
        Color.lerp(rightBaseColor, Colors.black, 0.18)!
            .withValues(alpha: opacity),
      ],
    );

    final rightPaint = Paint()
      ..shader = rightGradient.createShader(rightFacePath.getBounds())
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightFacePath, rightPaint);

    // 4. TOP FACE (Bright diamond with soft directional lighting)
    final topFacePath = Path()
      ..moveTo(vBack.dx, vBack.dy)
      ..lineTo(vRight.dx, vRight.dy)
      ..lineTo(vFront.dx, vFront.dy)
      ..lineTo(vLeft.dx, vLeft.dy)
      ..close();

    final topBaseColor = Color.lerp(baseColor, Colors.white, 0.22)!;
    final topBounds = topFacePath.getBounds();
    final topGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(topBaseColor, Colors.white, 0.32)!
            .withValues(alpha: opacity),
        topBaseColor.withValues(alpha: opacity),
        Color.lerp(topBaseColor, baseColor, 0.30)!
            .withValues(alpha: opacity),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final topPaint = Paint()
      ..shader = topGradient.createShader(topBounds)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topFacePath, topPaint);

    // 5. SUBTLE SURFACE MARBLE SPECULAR HIGHLIGHTS (Clean polished stone, no center split)
    if (width > 20.0) {
      canvas.save();
      canvas.clipPath(topFacePath);

      // Subtle diagonal soft specular sheen
      final sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-0.6, -1.0),
          end: const Alignment(0.6, 1.0),
          colors: [
            Colors.white.withValues(alpha: 0.18 * opacity),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.08 * opacity),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(topBounds)
        ..style = PaintingStyle.fill;
      canvas.drawPath(topFacePath, sheenPaint);

      canvas.restore();
    }

    // 6. CRISP EDGES & DIRECTIONAL HIGHLIGHTS
    // Luminous top rim outline
    final topOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(topFacePath, topOutlinePaint);

    // Front vertical center ridge (closest corner to the camera)
    final ridgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(vFront, vFrontBot, ridgePaint);

    // Left and right side perimeter outlines
    final sideOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(vLeft, vLeftBot, sideOutlinePaint);
    canvas.drawLine(vRight, vRightBot, sideOutlinePaint);

    // Bottom crease shadow
    final bottomShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(vLeftBot, vFrontBot, bottomShadowPaint);
    canvas.drawLine(vFrontBot, vRightBot, bottomShadowPaint);

    if (hasOffset) {
      canvas.restore();
    }
  }
}
