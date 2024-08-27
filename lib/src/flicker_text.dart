import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flicker_text/extension/rect_x.dart';
import 'package:flicker_text/models/particle.dart';
import 'package:flicker_text/models/string_details.dart';
import 'package:flicker_text/widgets/spoiler_richtext.dart';

class FlickerText extends StatefulWidget {
  const FlickerText({
    super.key,
    this.particleColor = Colors.white70,
    this.maxParticleSize = 1,
    this.particleDensity = 20,
    this.speedOfParticles = 0.2,
    this.fadeRadius = 10,
    this.enable = false,
    this.fadeAnimation = false,
    this.enableGesture = false,
    this.selection,
    this.tapShow = false,
    this.showDurationInSeconds = 3,
    required this.text,
    this.style,
  });

  final double particleDensity;
  final double speedOfParticles;
  final Color particleColor;
  final double maxParticleSize;
  final bool fadeAnimation;
  final double fadeRadius;
  final bool enable;
  final bool enableGesture;
  final TextStyle? style;
  final String text;
  final TextSelection? selection;
  final bool
      tapShow; // New parameter to enable/disable tap-to-show functionality
  final int
      showDurationInSeconds; // New parameter to set the duration in seconds for showing the text

  @override
  State createState() => _FlickerTextState();
}

class _FlickerTextState extends State<FlickerText>
    with TickerProviderStateMixin {
  final rng = Random();
  AnimationController? fadeAnimationController;
  Animation<double>? fadeAnimation;
  Future<void>? _currentShowFuture;
  bool _isShowingText = false;

  late final AnimationController particleAnimationController;
  late final Animation<double> particleAnimation;
  List<Rect> spoilerRects = [];
  Rect spoilerBounds = Rect.zero;
  final particles = <Particle>[];
  bool enabled = false;

  Offset fadeOffset = Offset.zero;
  Path spoilerPath = Path();

  Particle randomParticle(Rect rect) {
    final offset = rect.deflate(widget.fadeRadius).randomOffset();

    return Particle(
      offset.dx,
      offset.dy,
      widget.maxParticleSize,
      widget.particleColor,
      rng.nextDouble(),
      widget.speedOfParticles,
      rng.nextDouble() * 2 * pi,
      rect,
    );
  }

  void initializeOffsets(StringDetails details) {
    debugPrint('initializeOffsets');
    particles.clear();
    spoilerPath.reset();

    spoilerRects =
        details.words.map((e) => e.rect.deflate(widget.fadeRadius)).toList();
    spoilerBounds = spoilerRects.getBounds();

    for (final word in details.words) {
      spoilerPath.addRect(word.rect);

      final count =
          (word.rect.width + word.rect.height) * widget.particleDensity;
      for (int index = 0; index < count; index++) {
        particles.add(randomParticle(word.rect));
      }
    }
  }

  @override
  void initState() {
    particleAnimationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    particleAnimation = Tween<double>(begin: 0, end: 1)
        .animate(particleAnimationController)
      ..addListener(_myListener);

    if (widget.fadeAnimation) {
      fadeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      fadeAnimation =
          Tween<double>(begin: 0, end: 1).animate(fadeAnimationController!);
    }

    enabled = widget.enable;

    if (enabled) {
      _onEnabledChanged(widget.enable);
    }

    _onTapRecognizer = TapGestureRecognizer()
      ..onTapUp = (details) {
        fadeOffset = details.localPosition;

        if (_isShowingText) {
          return;
        }

        if (widget.tapShow &&
            spoilerRects.any((rect) => rect.contains(fadeOffset))) {
          _showTextTemporarily();
        } else if (widget.enable &&
            spoilerRects.any((rect) => rect.contains(fadeOffset))) {
          setState(() {
            _onEnabledChanged(!enabled);
          });
        }
      };

    super.initState();
  }

  @override
  void dispose() {
    _onTapRecognizer.dispose();
    fadeAnimationController?.dispose();
    particleAnimationController.dispose();
    super.dispose();
  }

  void _myListener() {
    setState(() {
      for (int index = 0; index < particles.length; index++) {
        final offset = particles[index];

        particles[index] =
            offset.life <= 0.1 ? randomParticle(offset.rect) : offset.move();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FlickerText oldWidget) {
    if (oldWidget.selection != widget.selection ||
        oldWidget.style != widget.style) {
      particles.clear();
    }

    if (oldWidget.enable != widget.enable) {
      _onEnabledChanged(widget.enable);
    }

    super.didUpdateWidget(oldWidget);
  }

  void _onEnabledChanged(bool enable) {
    if (enable) {
      setState(() => enabled = true);
      particleAnimationController.repeat();
      fadeAnimationController?.forward();
    } else {
      if (fadeAnimationController == null) {
        stopAnimation();
      } else {
        fadeAnimationController!.reverse().whenCompleteOrCancel(() {
          stopAnimation();
        });
      }
    }
  }

  void stopAnimation() {
    setState(() {
      enabled = false;
      particleAnimationController.reset();
      particles.clear();
    });
  }

  void _showTextTemporarily() {
    setState(() {
      _isShowingText = true;
      enabled = false;
    });

    _currentShowFuture?.then((_) => _currentShowFuture = null);

    _currentShowFuture =
        Future.delayed(Duration(seconds: widget.showDurationInSeconds), () {
      if (mounted) {
        setState(() {
          _isShowingText = false;
          enabled = true;
        });
      }
    });
  }

  late final TapGestureRecognizer _onTapRecognizer;

  @override
  Widget build(BuildContext context) {
    return SpoilerRichText(
      onBoundariesCalculated: initializeOffsets,
      key: UniqueKey(),
      selection: widget.selection,
      onPaint: (context, offset, superPaint) {
        if (!enabled) {
          superPaint(context, offset);
          return;
        }

        final isAnimating = fadeAnimationController != null &&
            fadeAnimationController!.isAnimating;

        late final double radius;
        late final Offset center;

        void updateRadius() {
          final farthestPoint =
              spoilerBounds.getFarthestPoint(fadeOffset + offset);
          final distance = (farthestPoint - (fadeOffset + offset)).distance;
          radius = distance * fadeAnimation!.value;
          center = fadeOffset + offset;
        }

        if (isAnimating) {
          updateRadius();
        }

        for (final point in particles) {
          final paint = Paint()
            ..strokeWidth = point.size
            ..color = point.color
            ..style = PaintingStyle.fill;

          if (isAnimating) {
            if ((center - point).distance < radius) {
              if ((center - point).distance > radius - 20) {
                context.canvas.drawCircle(point + offset, point.size * 1.5,
                    paint..color = Colors.white);
              } else {
                context.canvas.drawCircle(point + offset, point.size, paint);
              }
            }
          } else {
            context.canvas.drawCircle(point + offset, point.size, paint);
          }
        }

        void drawSplashAnimation() {
          final rect = Rect.fromCircle(center: center, radius: radius);

          final path = Path.combine(
            PathOperation.difference,
            Path()..addRect(spoilerBounds),
            Path()..addOval(rect),
          );

          context.pushClipPath(true, offset, rect, path, superPaint);
        }

        if (isAnimating) {
          drawSplashAnimation();
        }

        if (widget.selection != null) {
          final path = Path.combine(
            PathOperation.difference,
            Path()..addRect(context.estimatedBounds),
            spoilerPath,
          );

          context.pushClipPath(
              true, offset, context.estimatedBounds, path, superPaint);
        }
      },
      initialized: particles.isNotEmpty,
      text: TextSpan(
        text: widget.text,
        recognizer: widget.enableGesture ? _onTapRecognizer : null,
        style: widget.style,
      ),
    );
  }
}
