
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class IngredientBody extends BodyComponent {
  final Vector2 initialPosition;
  final Color color;
  final double radius;
  final String ingredientId;

  IngredientBody({
    required this.initialPosition,
    this.color = const Color(0xFF00FF00), // Default Green
    this.radius = 2.5,
    this.ingredientId = 'unknown',
  });

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.2, // Low bounciness for stacking
      friction: 0.8,    // High friction to prevent sliding
      density: 1.0,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.dynamic, 
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      radius, 
      Paint()..color = color,
    );
  }
}
