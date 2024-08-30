import 'package:flicker_text/flicker_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SpoilerTextExampleApp());
}

class SpoilerTextExampleApp extends StatelessWidget {
  const SpoilerTextExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Spoiler Animation Example'),
        ),
        body: const Center(
          child: SpoilerTextWidget(
            text: '11111111',
            showDurationInSeconds: 3,
          ),
        ),
      ),
    );
  }
}
