/// The `newton_particles` library provides a highly configurable particle emitter to create
/// captivating animations, such as rain, smoke, or explosions, in Flutter apps.
///
/// To use the `newton` library, import it in your Dart code and add a `Newton` widget
/// to your widget tree. The `Newton` widget allows you to add and manage different particle
/// effects by providing a list of `Effect` instances. It handles the animation and rendering
/// of the active particle effects on a custom canvas.
library newton_particles;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:newton_particles/newton_particles.dart';
import 'package:newton_particles/src/newton_painter.dart';
import 'package:newton_particles/src/utils/bundle_extensions.dart';

/// The `Newton` widget is the entry point for creating captivating particle animations.
///
/// Use the `Newton` widget to add and manage different particle effects like rain, smoke,
/// or explosions in your Flutter app. Pass a list of `Effect` instances to the `activeEffects`
/// parameter to create the desired particle animations. The `Newton` widget handles the animation
/// and rendering of the active particle effects on a custom canvas.
class Newton extends StatefulWidget {
  /// The list of active particle effects to be rendered.
  final List<Effect> activeEffects;

  /// Callback called when effect state has changed. See [EffectState].
  final void Function(Effect, EffectState)? onEffectStateChanged;

  const Newton({
    this.activeEffects = const [],
    this.onEffectStateChanged,
    super.key,
  });

  @override
  State<Newton> createState() => NewtonState();
}

/// The `NewtonState` class represents the state for the `Newton` widget.
///
/// The `NewtonState` class extends `State` and implements `SingleTickerProviderStateMixin`,
/// allowing it to create a ticker for handling animations. It manages the active particle effects
/// and handles their animation updates. Additionally, it uses a `CustomPainter` to render the
/// particle effects on a custom canvas.
class NewtonState extends State<Newton> with SingleTickerProviderStateMixin {
  static const _shapeSpriteSheetPath =
      "packages/newton_particles/assets/images/newton.png";
  late Ticker _ticker;
  int _lastElapsedMillis = 0;
  final List<Effect> _activeEffects = List.empty(growable: true);
  final List<Effect> _pendingActiveEffects = List.empty(growable: true);
  late Future<ui.Image> _shapeSpriteSheet;

  @override
  void initState() {
    super.initState();
    _shapeSpriteSheet = rootBundle.loadImage(_shapeSpriteSheetPath);
    _setupEffectsFromWidget();
    _ticker = createTicker(_onFrameUpdate);
    _ticker.start();
  }

  void _onFrameUpdate(elapsed) {
    _cleanDeadEffects();
    _updateActiveEffects(elapsed);
  }

  void _cleanDeadEffects() {
    _activeEffects.removeWhere((effect) => effect.state == EffectState.killed);
  }

  void _updateActiveEffects(Duration elapsed) {
    if (_pendingActiveEffects.isNotEmpty) {
      _activeEffects.addAll(_pendingActiveEffects);
      _pendingActiveEffects.clear();
    }
    if (_activeEffects.isNotEmpty) {
      for (var element in _activeEffects) {
        element.forward(elapsed.inMilliseconds - _lastElapsedMillis);
      }
      _lastElapsedMillis = elapsed.inMilliseconds;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _shapeSpriteSheet,
        builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          if (snapshot.hasData) {
            return RepaintBoundary(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                for (var effect in _activeEffects) {
                  effect.surfaceSize = constraints.biggest;
                }
                return CustomPaint(
                  willChange: true,
                  painter: NewtonPainter(
                    shapesSpriteSheet: snapshot.data!,
                    effects: _activeEffects,
                  ),
                );
              }),
            );
          } else {
            return Container();
          }
        });
  }

  /// Adds a new particle effect to the list of active effects.
  ///
  /// The `addEffect` method allows you to dynamically add a new particle effect to the list
  /// of active effects. Simply provide an `Effect` instance representing the desired effect,
  /// and the `Newton` widget will render it on the canvas.
  addEffect(Effect effect) {
    setState(() {
      _activeEffects.add(
        effect
          ..surfaceSize = MediaQuery.of(context).size
          ..postEffectCallback = _onPostEffect
          ..stateChangeCallback = _onEffectStateChanged,
      );
    });
  }

  @override
  void dispose() {
    _ticker.stop(canceled: true);
    _ticker.dispose();
    super.dispose();
  }

  void clearEffects() {
    _activeEffects.removeWhere((effect) {
      effect.postEffectCallback = null;
      return true;
    });
  }

  @override
  void didUpdateWidget(Newton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupEffectsFromWidget();
  }

  void _setupEffectsFromWidget() {
    _pendingActiveEffects.clear();
    _activeEffects
      ..clear()
      ..addAll(widget.activeEffects);
    for (var effect in _activeEffects) {
      effect
        ..postEffectCallback = _onPostEffect
        ..stateChangeCallback = _onEffectStateChanged;
    }
  }

  _onPostEffect(Effect<AnimatedParticle> effect) {
    _pendingActiveEffects.add(effect
      ..postEffectCallback = _onPostEffect
      ..stateChangeCallback = _onEffectStateChanged);
  }

  _onEffectStateChanged(Effect effect, EffectState state) {
    widget.onEffectStateChanged?.call(effect, state);
  }
}
