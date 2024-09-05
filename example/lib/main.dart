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
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SpoilerTextWidget(
                    showDurationInSeconds: 3,
                    maxParticleSize: 1,
                    particleDensity: 20,
                    speedOfParticles: 0.2,
                    enableGesture: true,
                    enable: true,
                    text: '123',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: SpoilerTextWidget(
                    showDurationInSeconds: 3,
                    maxParticleSize: 1,
                    particleDensity: 10,
                    speedOfParticles: 0.1,
                    enableGesture: true,
                    enable: true,
                    text: '12312313',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: SpoilerTextWidget(
                    showDurationInSeconds: 3,
                    maxParticleSize: 1,
                    particleDensity: 20,
                    speedOfParticles: 0.1,
                    enableGesture: true,
                    enable: true,
                    text: '1',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: SpoilerTextWidget(
                    showDurationInSeconds: 3,
                    maxParticleSize: 1,
                    particleDensity: 10,
                    speedOfParticles: 0.1,
                    enableGesture: true,
                    enable: true,
                    text: '1231231233',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: SpoilerTextWidget(
                    showDurationInSeconds: 3,
                    maxParticleSize: 1,
                    particleDensity: 10,
                    speedOfParticles: 0.1,
                    enableGesture: true,
                    enable: true,
                    text: '123123123123123',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
