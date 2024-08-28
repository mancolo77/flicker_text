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
          child: FlickerText(
            showDurationInSeconds: 3,
            tapWithTimer: true,
            maxParticleSize: 1,
            particleDensity: 10,
            speedOfParticles: 0.1,
            fadeRadius: 1,
            fadeAnimation: true,
            enableGesture: false,
            enable: true,
            text: '12312312',
          ),
        ),
      ),
    );
  }
}
