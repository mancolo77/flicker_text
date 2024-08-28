import 'dart:math';
import 'dart:ui' show Color, Offset, Rect;

/// Particle class to represent a single particle
///
/// This class is used to represent a single particle in the particle system.
/// It contains the position, size, color, life, speed, angle, and rect of the particle.
class Particle extends Offset {
  /// The size of the particle.
  final double size;

  /// The color of the particle.
  final Color color;

  /// Value between 0 and 1 representing the life of the particle.
  final double life;

  /// Value representing the speed of the particle in pixels per frame.
  final double speed;

  /// Value representing the angle of the particle in radians.
  final double angle;

  /// The rect where the particle is located.
  final Rect rect;

  /// The center of the particle's initial position.
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

  /// Copy the particle with new values
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

  /// Move the particle relative to the center
  ///
  /// This method is used to move the particle relative to its center.
  /// It calculates the next position of the particle based on the current position, speed, angle, and center.
  Particle move() {
    final offsetFromCenter =
        this - center; // Calculate current offset from center
    final nextOffsetFromCenter =
        offsetFromCenter + Offset.fromDirection(angle, speed);

    final next = center +
        nextOffsetFromCenter; // Calculate the new position relative to the center

    final lifetime = life - 0.01;
    final color = lifetime > .1 ? this.color.withOpacity(lifetime) : this.color;

    return copyWith(
      dx: next.dx,
      dy: next.dy,
      life: lifetime,
      color: color,
      angle: angle + (Random().nextDouble() - 0.5) * 0.5,
    );
  }

  bool isWithinRadius(Offset checkCenter, double radius) {
    return (this - checkCenter).distance <= radius;
  }
}
