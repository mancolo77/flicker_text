import 'dart:async';
import 'dart:math';

import 'package:flicker_text/extension/rect_x.dart';
import 'package:flicker_text/models/particle.dart';
import 'package:flicker_text/models/string_details.dart';
import 'package:flicker_text/widgets/spoiler_richtext.dart';
import 'package:flutter/material.dart';

class SpoilerTextWidget extends StatefulWidget {
  const SpoilerTextWidget({
    super.key,
    this.particleColor = Colors.white70,
    this.maxParticleSize = 1,
    this.particleDensity = 10,
    this.speedOfParticles = 0.2,
    this.fadeRadius = 1,
    this.enable = true,
    this.fadeAnimation = true,
    this.enableGesture = true,
    this.selection,
    required this.text,
    this.style,
    this.showDurationInSeconds = 3,
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
  final int showDurationInSeconds;

  @override
  State createState() => _SpoilerTextWidgetState();
}

class _SpoilerTextWidgetState extends State<SpoilerTextWidget>
    with TickerProviderStateMixin {
  final rng = Random();

  AnimationController? fadeAnimationController;
  Animation<double>? fadeAnimation;

  late final AnimationController particleAnimationController;
  late final Animation<double> particleAnimation;
  List<Rect> spoilerRects = [];
  Rect spoilerBounds = Rect.zero;
  final particles = <Particle>[];
  bool enabled = false;
  bool _isShowingText = false;
  Future<void>? _currentShowFuture;

  late double currentParticleSize;
  late double initialParticleSize;
  late double currentFadeRadius;
  late double initialFadeRadius;
  Timer? _timer;

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

    initialParticleSize = widget.maxParticleSize;
    currentParticleSize = initialParticleSize;
    initialFadeRadius = widget.fadeRadius;
    currentFadeRadius = initialFadeRadius;

    enabled = widget.enable;

    if (enabled) {
      _onEnabledChanged(widget.enable);
    }

    super.initState();
  }

  void _myListener() {
    setState(
      () {
        for (int index = 0; index < particles.length; index++) {
          final offset = particles[index];

          // If particle is dead, replace it with a new one
          // Otherwise, move it
          particles[index] =
              offset.life <= 0.1 ? randomParticle(offset.rect) : offset.move();
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant SpoilerTextWidget oldWidget) {
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

  @override
  void dispose() {
    particleAnimation.removeListener(_myListener);
    particleAnimationController.dispose();
    fadeAnimationController?.dispose();
    super.dispose();
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
        _startIncreasingParticleSize();
      }
    });
  }

  void _startIncreasingParticleSize() {
    if (_timer != null) _timer!.cancel();

    const double increaseDurationInSeconds = 1.0; // Duration of increase
    final int numberOfSteps = (increaseDurationInSeconds * 1000 / 10)
        .round(); // Determine number of steps
    final double stepSize = initialParticleSize / numberOfSteps; // Step size
    final double fadeStepSize = initialFadeRadius / numberOfSteps;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (currentParticleSize < initialParticleSize ||
            currentFadeRadius < initialFadeRadius) {
          currentParticleSize =
              (currentParticleSize + stepSize).clamp(0.0, initialParticleSize);
          currentFadeRadius =
              (currentFadeRadius + fadeStepSize).clamp(0.0, initialFadeRadius);
        } else {
          _timer?.cancel();
          setState(() {
            _isShowingText = false; // Mark text as hidden
            enabled = true; // Enable particles again
          });
          particleAnimationController.repeat();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        fadeOffset = details.localPosition;
        if (_isShowingText) {
          return;
        }
        if (widget.enableGesture &&
            spoilerRects.any((rect) => rect.contains(fadeOffset))) {
          _showTextTemporarily();
        } else if (widget.enable &&
            spoilerRects.any((rect) => rect.contains(fadeOffset))) {
          setState(() {
            _onEnabledChanged(!enabled);
          });
        }
      },
      child: SpoilerRichText(
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
          style: widget.style,
        ),
      ),
    );
  }
}
