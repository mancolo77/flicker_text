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
    this.enable = true,
    this.enableGesture = true,
    this.selection,
    required this.text,
    this.style,
    this.showDurationInSeconds = 3,
  });

  final double particleDensity;
  final Color particleColor;
  final double maxParticleSize;
  final double speedOfParticles;
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
  late final AnimationController particleAnimationController;
  late final Animation<double> particleAnimation;
  final particles = <Particle>[];
  bool enabled = false;
  late double currentParticleSize;
  late double initialParticleSize;
  bool _isShowingText = false;
  Timer? _timer;
  Offset fadeOffset = Offset.zero;
  bool _isSpeedIncreased = false; // Flag to check speed increase state

  late double speedOfParticles; // Mutable field

  Particle randomParticle(Rect rect) {
    final offset = rect.randomOffset();
    return Particle(
      offset.dx,
      offset.dy,
      currentParticleSize,
      widget.particleColor,
      rng.nextDouble(),
      speedOfParticles, // Use the mutable speed here
      rng.nextDouble() * 2 * pi,
      rect,
    );
  }

  void initializeOffsets(StringDetails details) {
    particles.clear();
    for (final word in details.words) {
      final count =
          (word.rect.width + word.rect.height) * widget.particleDensity;

      // Ensure a minimum number of particles
      final effectiveCount =
          count < 1 ? 5 : count.toInt(); // Minimum 5 particles

      for (int index = 0; index < effectiveCount; index++) {
        particles.add(randomParticle(word.rect));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    particleAnimationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    particleAnimation = Tween<double>(begin: 0, end: 1)
        .animate(particleAnimationController)
      ..addListener(_myListener);

    initialParticleSize = widget.maxParticleSize;
    currentParticleSize = initialParticleSize;
    enabled = widget.enable;
    speedOfParticles = widget.speedOfParticles; // Initialize speed
    if (enabled) {
      _onEnabledChanged(widget.enable);
    }
  }

  void _myListener() {
    if (mounted) {
      setState(() {
        for (int index = 0; index < particles.length; index++) {
          final offset = particles[index];
          particles[index] =
              offset.life <= 0.1 ? randomParticle(offset.rect) : offset.move();
        }
      });
    }
  }

  void _showTextTemporarily() {
    setState(() {
      _isShowingText = true;
      enabled = false;
    });
    _timer = Timer(Duration(seconds: widget.showDurationInSeconds), () {
      if (mounted) {
        setState(() {
          _isShowingText = false;
          enabled = true;
        });
        _startIncreasingParticleSize();
      }
    });
  }

  void _startDecreasingParticleSize() {
    final int numberOfSteps =
        (widget.showDurationInSeconds * 1000 / 30).round();
    final double stepSize = initialParticleSize / numberOfSteps;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        setState(() {
          if (currentParticleSize > 0) {
            currentParticleSize = (currentParticleSize - stepSize)
                .clamp(0.0, initialParticleSize);
          } else {
            timer.cancel();
            setState(() {
              _isShowingText = true;
              enabled = true;
            });
            _startIncreasingParticleSize();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startIncreasingParticleSize() {
    final int numberOfSteps =
        (widget.showDurationInSeconds * 1000 / 100).round();
    final double stepSize = initialParticleSize / numberOfSteps;
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (mounted) {
        setState(() {
          if (currentParticleSize < initialParticleSize) {
            currentParticleSize = (currentParticleSize + stepSize)
                .clamp(0.0, initialParticleSize);
          } else {
            speedOfParticles = widget.speedOfParticles;
            timer.cancel();
            setState(() {
              _isShowingText = false;
              enabled = true;
            });
            particleAnimationController.repeat();
            _resetSpeedOfParticles(); // Reset speed after increasing particle size
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resetSpeedOfParticles() {
    setState(() {
      speedOfParticles = widget.speedOfParticles; // Reset to the original speed
      _isSpeedIncreased = false; // Allow speed to be increased again
    });
  }

  void _onEnabledChanged(bool enable) {
    setState(() => enabled = enable);
    if (enable) {
      particleAnimationController.repeat();
    } else {
      particleAnimationController.stop();
      particles.clear();
    }
  }

  @override
  void dispose() {
    particleAnimation.removeListener(_myListener);
    particleAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        if (_isSpeedIncreased) return;
        fadeOffset = details.localPosition * 2;
        _startDecreasingParticleSize();
        if (_isShowingText) return;
        if (widget.enableGesture) {
          _showTextTemporarily();
        } else if (widget.enable) {
          setState(() {
            _onEnabledChanged(!enabled);
          });
        }

        setState(() {
          speedOfParticles = 1;
          _isSpeedIncreased = true;
        });
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
          for (final point in particles) {
            final paint = Paint()
              ..strokeWidth = point.size * 2
              ..color = point.color
              ..style = PaintingStyle.fill;
            context.canvas.drawCircle(point + offset, point.size, paint);
          }
        },
        initialized: particles.isNotEmpty,
        text: TextSpan(
          text: !enabled ? widget.text : '1234556',
          style: widget.style,
        ),
      ),
    );
  }
}
