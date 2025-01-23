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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black, brightness: Brightness.dark),
        canvasColor: const Color(0xff1b1b1d),
      ),
      home: newton.Newton(
        effectConfigurations: [
          // Emulate light balls falling
          newton.RelativisticEffectConfiguration(
            gravity: newton.Gravity.zero,
            origin: Offset.zero,
            maxOriginOffset: const Offset(1, 0),
            maxAngle: 180,
            maxEndScale: 1,
            maxFadeOutThreshold: 0.8,
            maxParticleLifespan: const Duration(seconds: 3),
            minAngle: 90,
            minEndScale: 1,
            minFadeOutThreshold: 0.6,
            onlyInteractWithEdges: true,
            maxVelocity: newton.Velocity(0.1),
            minParticleLifespan: const Duration(seconds: 1),
            particleConfiguration: const newton.ParticleConfiguration(
              shape: newton.RectangleShape(),
              size: Size(5, 5),
            ),
          ),
        ],
      ),
    );
  }
}
