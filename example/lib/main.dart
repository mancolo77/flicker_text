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
            enable: true,
            maxParticleSize: 1.5,
            particleDensity: .4,
            speedOfParticles: 0.3,
            fadeRadius: 1,
            fadeAnimation: true,
            enableGesture: true,
            text: '12312323',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
