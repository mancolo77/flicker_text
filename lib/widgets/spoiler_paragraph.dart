import 'package:flutter/rendering.dart';
import 'package:flicker_text/models/string_details.dart';

typedef PaintCallback = void Function(
  PaintingContext context,
  Offset offset,
  void Function(PaintingContext context, Offset offset) superPaint,
);

class SpoilerParagraph extends RenderParagraph {
  final bool initialized;
  final ValueSetter<StringDetails> onBoundariesCalculated;
  final PaintCallback? onPaint;
  final TextSelection? selection;
  final double fixedWidth; // Fixed width for rectangles
  final double fixedHeight; // Fixed height for rectangles

  SpoilerParagraph(
    super.text, {
    required super.textDirection,
    required this.onBoundariesCalculated,
    this.onPaint,
    this.selection,
    required this.initialized,
    this.fixedWidth = 50.0, // Default fixed width
    this.fixedHeight = 20.0, // Default fixed height
  });

  /// Get list of words bounding boxes
  List<Word> getWords() {
    final text = this.text;
    final textPainter = TextPainter(
      text: text,
      textDirection: textDirection,
      textAlign: textAlign,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
    );
    textPainter.layout(
      minWidth: constraints.minWidth,
      maxWidth: constraints.maxWidth,
    );

    final textRuns = <Word>[];

    void getAllWordBoundaries(int offset, List<Word> list) {
      final range = textPainter.getWordBoundary(TextPosition(offset: offset));

      if (range.isCollapsed) return;

      final substr = text.toPlainText().substring(range.start, range.end);

      // Move to next word if current word is empty
      if (substr.trim().isEmpty) {
        getAllWordBoundaries(range.end, list);
        return;
      }

      // Calculate the actual position and size of the word
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(baseOffset: range.start, extentOffset: range.end),
      );

      for (final box in boxes) {
        // Position the rectangles around the word but use fixed dimensions
        final rect = Rect.fromLTWH(
          box.left,
          box.top,
          fixedWidth, // Fixed width
          fixedHeight, // Fixed height
        );

        textRuns.add(
          Word(
            word: substr,
            rect: rect,
            range: range,
          ),
        );
      }

      getAllWordBoundaries(range.end, list);
    }

    if (selection != null) {
      final boxes = textPainter.getBoxesForSelection(selection!);

      for (final box in boxes) {
        textRuns.add(
          Word(
            word:
                text.toPlainText().substring(selection!.start, selection!.end),
            rect: Rect.fromLTWH(
              box.left, // Keep the actual word's position
              box.top, // Keep the actual word's position
              fixedWidth, // Fixed width
              fixedHeight, // Fixed height
            ),
            range: TextRange(start: selection!.start, end: selection!.end),
          ),
        );
      }
    } else {
      getAllWordBoundaries(0, textRuns);
    }
    return textRuns;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!initialized) {
      final bounds = getWords();
      onBoundariesCalculated(StringDetails(words: bounds));
    }

    onPaint?.call(context, offset, super.paint);
  }
}
