import 'package:flutter/material.dart';
import 'package:newton_particles/newton_particles.dart' as newton;

void main() {
  runApp(const NewtonExampleApp());
}

class NewtonExampleApp extends StatelessWidget {
  const NewtonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      darkTheme: ThemeData(
        canvasColor: Colors.white,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: newton.Newton(
          shapeSpriteSheetPath: 'lib/sheet.png',
          effectConfigurations: [
            // Emulate light balls falling
            newton.DeterministicEffectConfiguration(
              origin: Offset(0.4, 0.4),
              maxOriginOffset: const Offset(0.2, 0.2),
              minOriginOffset: const Offset(0, 0),
              emitDuration: Duration(milliseconds: 10),
              particlesPerEmit: 2,
              particleCount: 200,
              maxAngle: 180,
              maxFadeOutThreshold: 0.8,
              minFadeInThreshold: 0.1,
              maxFadeInThreshold: 0.2,
              minAngle: -180,
              minEndScale: 5,
              maxEndScale: 20,
              minBeginScale: 0,
              maxBeginScale: 0.1,
              scaleCurve: Curves.easeInExpo,
              distanceCurve: Curves.easeInExpo,
              minFadeOutThreshold: 0.6,
              maxDistance: 1000,
              minDistance: 400,
              minParticleLifespan: const Duration(seconds: 4),
              maxParticleLifespan: const Duration(seconds: 5),
              particleConfiguration: newton.ParticleConfiguration(
                shape:
                    newton.SpritesheetShape(spriteWidth: 285, spriteIndex: 4),
                size: Size.square(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
