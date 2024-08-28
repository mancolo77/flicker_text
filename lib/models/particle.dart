import 'dart:math';
import 'dart:ui' show Color, Offset, Rect;

/// Particle class to represent a single particle
///
/// This class is used to represent a single particle in the particle system.
/// It contains the position, size, color, life, speed, angle, and rect of the particle.
class Particle extends Offset {
  final double size;
  final Color color;
  final double life;
  final double speed;
  final double angle;
  final Rect rect;
  final Offset center;

  const Particle(
    super.dx,
    super.dy,
    this.size,
    this.color,
    this.life,
    this.speed,
    this.angle,
    this.rect, {
    required this.center,
  });

  Particle copyWith({
    double? dx,
    double? dy,
    double? size,
    Color? color,
    double? life,
    double? speed,
    double? angle,
    Rect? rect,
    Offset? center,
  }) {
    return Particle(
      dx ?? this.dx,
      dy ?? this.dy,
      size ?? this.size,
      color ?? this.color,
      life ?? this.life,
      speed ?? this.speed,
      angle ?? this.angle,
      rect ?? this.rect,
      center: center ?? this.center,
    );
  }

  Particle move() {
    final offsetFromCenter = this - center;
    final nextOffsetFromCenter =
        offsetFromCenter + Offset.fromDirection(angle, speed);
    final next = center + nextOffsetFromCenter;

    final lifetime = life - 0.01;
    final updatedColor = lifetime > 0.1 ? color.withOpacity(lifetime) : color;

    return copyWith(
      dx: next.dx,
      dy: next.dy,
      life: lifetime,
      color: updatedColor,
      angle: angle + (Random().nextDouble() - 0.5) * 0.5,
    );
  }

  bool isWithinRadius(Offset checkCenter, double radius) {
    return (this - checkCenter).distance <= radius;
  }
}
