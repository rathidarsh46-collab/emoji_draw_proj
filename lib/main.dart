// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const EmojiDrawingApp());
}

enum EmojiType { smiley, party, heart }

class EmojiDrawingApp extends StatelessWidget {
  const EmojiDrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Emoji Drawing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const EmojiHomeScreen(),
    );
  }
}

class EmojiHomeScreen extends StatefulWidget {
  const EmojiHomeScreen({super.key});

  @override
  State<EmojiHomeScreen> createState() => _EmojiHomeScreenState();
}

class _EmojiHomeScreenState extends State<EmojiHomeScreen> {
  EmojiType _selected = EmojiType.smiley;
  double _scale = 1.0;
  final List<Offset> _confettiPositions = List.generate(
    18,
    (i) {
      final seed = i * 37 + 13;
      final rng = Random(seed);
      return Offset(rng.nextDouble() * 2 - 1, rng.nextDouble() * 2 - 1);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Emoji Drawing'),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Interactive Emoji Drawing',
              children: const [
                Text('Draws several emoji types using CustomPainter.'),
              ],
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F8FF), Color(0xFFE6F7FF)],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Select emoji: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<EmojiType>(
                  value: _selected,
                  items: const [
                    DropdownMenuItem(
                      value: EmojiType.smiley,
                      child: Text('Smiley Face'),
                    ),
                    DropdownMenuItem(
                      value: EmojiType.party,
                      child: Text('Party Face'),
                    ),
                    DropdownMenuItem(
                      value: EmojiType.heart,
                      child: Text('Heart'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selected = v);
                  },
                ),
                const Spacer(),
                const Text('Size'),
                Slider(
                  value: _scale,
                  min: 0.6,
                  max: 1.6,
                  divisions: 10,
                  label: '${(_scale * 100).round()}%',
                  onChanged: (v) => setState(() => _scale = v),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: SizedBox(
                  width: 360 * _scale,
                  height: 360 * _scale,
                  child: CustomPaint(
                    painter: EmojiPainter(
                      emojiType: _selected,
                      confettiPositions: _confettiPositions,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Tips: Use the dropdown to switch emojis. '
              'The Party Face includes a hat + confetti; the Heart uses a path.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class EmojiPainter extends CustomPainter {
  final EmojiType emojiType;
  final List<Offset> confettiPositions;

  EmojiPainter({
    required this.emojiType,
    required this.confettiPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double side = min(size.width, size.height);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double faceRadius = side * 0.38;

    switch (emojiType) {
      case EmojiType.smiley:
        _drawSmiley(canvas, center, faceRadius);
        break;
      case EmojiType.party:
        _drawPartyFace(canvas, center, faceRadius);
        break;
      case EmojiType.heart:
        _drawHeart(canvas, center, faceRadius);
        break;
    }
  }

// smiley face
  void _drawSmiley(Canvas canvas, Offset center, double r) {
    final Rect faceRect = Rect.fromCircle(center: center, radius: r);
    final Paint facePaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFFFF176), const Color(0xFFFBC02D)],
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
      ).createShader(faceRect);

    canvas.drawCircle(center, r, facePaint);

    final Paint border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..color = Colors.orange.shade800;
    canvas.drawCircle(center, r, border);

    // eyes
    final double eyeOffsetX = r * 0.45;
    final double eyeOffsetY = r * 0.18;
    final double eyeRadius = r * 0.13;
    final Paint eyePaint = Paint()..color = Colors.black;
    // left eye
    canvas.drawCircle(center.translate(-eyeOffsetX, -eyeOffsetY), eyeRadius, eyePaint);
    // right eye
    canvas.drawCircle(center.translate(eyeOffsetX, -eyeOffsetY), eyeRadius, eyePaint);

    // mouth 
    final Paint smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round
      ..color = Colors.red.shade700;

    final Rect mouthRect = Rect.fromCenter(center: center.translate(0, r * 0.12), width: r * 1.4, height: r * 1.0);
    // smile
    canvas.drawArc(mouthRect, radians(20), radians(140), false, smilePaint);

    // tongue 
    final Paint tonguePaint = Paint()..color = Colors.pink.shade300;
    final Rect tongueRect = Rect.fromCenter(center: center.translate(0, r * 0.22), width: r * 0.6, height: r * 0.25);
    canvas.drawArc(tongueRect, radians(200), radians(140), false, tonguePaint..style = PaintingStyle.fill);

    // small cheek highlights
    final Paint cheekPaint = Paint()..color = Colors.white.withOpacity(0.35);
    canvas.drawCircle(center.translate(-r * 0.55, 0), r * 0.07, cheekPaint);
    canvas.drawCircle(center.translate(r * 0.55, 0), r * 0.07, cheekPaint);
  }

// party hat
  void _drawPartyFace(Canvas canvas, Offset center, double r) {
    // face
    final Rect faceRect = Rect.fromCircle(center: center, radius: r);
    final Paint facePaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFFFEE58), const Color(0xFFF9A825)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(faceRect);
    canvas.drawCircle(center, r, facePaint);

    // Eyes
    final double eyeOffsetX = r * 0.38;
    final double eyeOffsetY = r * 0.12;
    final double eyeRadius = r * 0.12;

    final Paint eyeFill = Paint()..color = Colors.black;
    canvas.drawCircle(center.translate(-eyeOffsetX, -eyeOffsetY), eyeRadius, eyeFill);
    canvas.drawCircle(center.translate(eyeOffsetX, -eyeOffsetY), eyeRadius, eyeFill);

    // eye sparkle
    final Paint sparkle = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(center.translate(-eyeOffsetX - eyeRadius * 0.25, -eyeOffsetY - eyeRadius * 0.25), eyeRadius * 0.35, sparkle);
    canvas.drawCircle(center.translate(eyeOffsetX - eyeRadius * 0.25, -eyeOffsetY - eyeRadius * 0.25), eyeRadius * 0.35, sparkle);

    // cheerful grin
    final Paint grinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.09
      ..strokeCap = StrokeCap.round
      ..color = Colors.deepPurple;
    final Rect grinRect = Rect.fromCenter(center: center.translate(0, r * 0.15), width: r * 1.25, height: r * 0.75);
    canvas.drawArc(grinRect, radians(25), radians(130), false, grinPaint);

    // party hat 
    final Path hat = Path();
    final Offset hatBaseLeft = center.translate(-r * 0.45, -r * 0.9);
    final Offset hatBaseRight = center.translate(r * 0.45, -r * 0.9);
    final Offset hatTip = center.translate(0, -r * 1.6);
    hat.moveTo(hatBaseLeft.dx, hatBaseLeft.dy);
    hat.lineTo(hatBaseRight.dx, hatBaseRight.dy);
    hat.lineTo(hatTip.dx, hatTip.dy);
    hat.close();

    final Rect hatRect = Rect.fromPoints(hatBaseLeft, hatTip);
    final Paint hatPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.pink, Colors.purple, Colors.blue]).createShader(hatRect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(hat, hatPaint);

    // hat brim
    final Paint brimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Rect brimRect = Rect.fromCenter(center: center.translate(0, -r * 0.9), width: r * 1.05, height: r * 0.16);
    canvas.drawRRect(RRect.fromRectAndRadius(brimRect, Radius.circular(r * 0.05)), brimPaint);

    // confetti
    final double confettiAreaRadius = r * 1.15;
    final List<Color> confettiColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal
    ];

    final Paint confPaint = Paint();
    for (int i = 0; i < confettiPositions.length; i++) {
      final pos = confettiPositions[i];
      final Offset p = center.translate(pos.dx * confettiAreaRadius * 0.9 + r * 0.6, pos.dy * confettiAreaRadius * 0.8 - r * 0.6);
      confPaint.color = confettiColors[i % confettiColors.length];
      final double size = (3 + (i % 5)) * (r / 60);
      switch (i % 3) {
        case 0:
          canvas.drawCircle(p, size * 0.9, confPaint);
          break;
        case 1:
          canvas.drawRect(Rect.fromCenter(center: p, width: size * 1.6, height: size * 1.6), confPaint);
          break;
        case 2:
          final Path t = Path();
          t.moveTo(p.dx, p.dy - size);
          t.lineTo(p.dx + size, p.dy + size);
          t.lineTo(p.dx - size, p.dy + size);
          t.close();
          canvas.drawPath(t, confPaint);
          break;
      }
    }
  }

// heart emoji
  void _drawHeart(Canvas canvas, Offset center, double r) {
    // Background circle behind heart
    final Paint back = Paint()
      ..shader = RadialGradient(colors: [Colors.pink.shade50, Colors.white]).createShader(
        Rect.fromCircle(center: center, radius: r * 1.15),
      );
    canvas.drawCircle(center, r * 1.15, back);

    final Path heart = Path();
    final double s = r * 0.9; 
    final Offset topCenter = center.translate(0, -s * 0.15);
    final double lobeRadius = s * 0.32;

    heart.moveTo(center.dx, center.dy + s * 0.45);

    heart.cubicTo(
      center.dx - s * 0.55, center.dy + s * 0.25,
      center.dx - s * 0.7, center.dy - s * 0.05,
      center.dx - s * 0.25, center.dy - s * 0.35,
    );

    heart.quadraticBezierTo(center.dx - s * 0.05, center.dy - s * 0.55, center.dx, center.dy - s * 0.32);

    heart.quadraticBezierTo(center.dx + s * 0.05, center.dy - s * 0.55, center.dx + s * 0.25, center.dy - s * 0.35);

    heart.cubicTo(
      center.dx + s * 0.7, center.dy - s * 0.05,
      center.dx + s * 0.55, center.dy + s * 0.25,
      center.dx, center.dy + s * 0.45,
    );

    heart.close();

    final Rect heartBounds = Rect.fromCenter(center: center, width: s * 1.4, height: s * 1.4);
    final Paint heartPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.pink.shade400, Colors.red.shade700], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(heartBounds)
      ..style = PaintingStyle.fill;

    canvas.drawPath(heart, heartPaint);

    final Paint highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04
      ..color = Colors.white.withOpacity(0.35);
    canvas.drawPath(heart, highlight);

    final Paint gloss = Paint()..color = Colors.white.withOpacity(0.18);
    final Path glossPath = Path()
      ..moveTo(center.dx - s * 0.28, center.dy - s * 0.2)
      ..quadraticBezierTo(center.dx - s * 0.05, center.dy - s * 0.3, center.dx + s * 0.1, center.dy - s * 0.05)
      ..lineTo(center.dx + s * 0.05, center.dy - s * 0.02)
      ..quadraticBezierTo(center.dx - s * 0.1, center.dy - s * 0.18, center.dx - s * 0.28, center.dy - s * 0.2)
      ..close();
    canvas.drawPath(glossPath, gloss);
  }

  @override
  bool shouldRepaint(covariant EmojiPainter oldDelegate) {
    return oldDelegate.emojiType != emojiType || oldDelegate.confettiPositions != confettiPositions;
  }

  double radians(double deg) => deg * pi / 180;
}
