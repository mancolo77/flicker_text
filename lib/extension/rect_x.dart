import 'dart:math';
import 'package:flutter/rendering.dart';

extension RectX on Rect {
  /// Check if [offset] is inside the rectangle
  ///
  /// Example:
  /// ```dart
  /// final rect = Rect.fromLTWH(0, 0, 100, 100);
  /// final offset = Offset(50, 50);
  ///
  /// rect.containsOffset(offset); // true
  /// ```
  bool containsOffset(Offset offset) {
    return bottom >= offset.dy &&
        top <= offset.dy &&
        left <= offset.dx &&
        right >= offset.dx;
  }

  /// Divide the rectangle into four smaller rectangles, centered around the original rectangle's center.
  (Rect, Rect, Rect, Rect) divideRect() {
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final centerX = center.dx;
    final centerY = center.dy;

    final topLeft = Rect.fromLTRB(
        centerX - halfWidth, centerY - halfHeight, centerX, centerY);
    final topRight = Rect.fromLTRB(
        centerX, centerY - halfHeight, centerX + halfWidth, centerY);
    final bottomLeft = Rect.fromLTRB(
        centerX - halfWidth, centerY, centerX, centerY + halfHeight);
    final bottomRight = Rect.fromLTRB(
        centerX, centerY, centerX + halfWidth, centerY + halfHeight);

    return (topLeft, topRight, bottomLeft, bottomRight);
  }

  /// Get the farthest corner from [offset] relative to the center of the rectangle.
  Offset getFarthestPoint(Offset offset) {
    final (topLeft, topRight, bottomLeft, bottomRight) = divideRect();

    if (topLeft.containsOffset(offset)) {
      return bottomRight.bottomRight;
    } else if (topRight.containsOffset(offset)) {
      return bottomLeft.bottomLeft;
    } else if (bottomLeft.containsOffset(offset)) {
      return topRight.topRight;
    } else if (bottomRight.containsOffset(offset)) {
      return topLeft.topLeft;
    } else {
      return center;
    }
  }

  /// Get a random offset inside the rectangle, centered around the rectangle's center.
  Offset randomOffset() {
    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final centerX = center.dx;
    final centerY = center.dy;

    final minX = centerX - halfWidth;
    final maxX = centerX + halfWidth;
    final minY = centerY - halfHeight;
    final maxY = centerY + halfHeight;

    return Offset(
      minX + (Random().nextDouble() * (maxX - minX)),
      minY + (Random().nextDouble() * (maxY - minY)),
    );
  }
}

extension ListRectX on List<Rect> {
  /// Calculate the bounding rectangle that contains all rectangles in the list.
  /// Center the result around the combined bounds.
  Rect getBounds() {
    if (isEmpty) {
      return Rect.zero;
    }

    var left = first.left;
    var top = first.top;
    var right = first.right;
    var bottom = first.bottom;

    for (final rect in this) {
      if (rect.left < left) {
        left = rect.left;
      }

      if (rect.top < top) {
        top = rect.top;
      }

      if (rect.right > right) {
        right = rect.right;
      }

      if (rect.bottom > bottom) {
        bottom = rect.bottom;
      }
    }

    final bounds = Rect.fromLTRB(left, top, right, bottom);
    final centerX = bounds.center.dx;
    final centerY = bounds.center.dy;

    return Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: bounds.width,
        height: bounds.height);
  }
}