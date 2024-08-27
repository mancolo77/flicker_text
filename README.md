##Flicker Text

improved spoiler text with click and time setting

## Example

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
            tapShow: true,
            enable: true,
            maxParticleSize: 1.5,
            particleDensity: .4,
            speedOfParticles: 0.3,
            fadeRadius: 1,
            fadeAnimation: true,
            enableGesture: true,
            selection: TextSelection(baseOffset: 0, extentOffset: 18),
            text: 'This is a spoiler! Tap to reveal.',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

## Additional information
original package: https://pub.dev/packages/spoiler_widget
