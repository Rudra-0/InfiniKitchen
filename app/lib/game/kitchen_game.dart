import 'package:app/game/components/ingredient_body.dart';
import 'package:flame/events.dart';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class KitchenGame extends Forge2DGame with TapDetector, PanDetector {
  KitchenGame() : super(gravity: Vector2(0, 50.0), zoom: 10.0); // High gravity, zoomed in.

  MouseJoint? mouseJoint;
  late Body groundBody;

  @override
  Color backgroundColor() => const Color(0xFF2A2A2A);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Create boundaries (walls)
    // We need to wait for the size to be known, usually it is available in onLoad if not mostly.
    // Best practice is to create boundaries in onResize or utilize the camera viewport.
    // For simplicity, we'll create a floor for now.
    
    final worldBounds = Rect.fromLTRB(0, 0, 100, 100); // Abstract world bounds
    createBoundaries(worldBounds);
    
    // Spawn a test ingredient (Water)
    add(IngredientBody(
      initialPosition: Vector2(20, 10),
      color: const Color(0xFF2196F3),
      ingredientId: 'water',
    ));
  }

  void spawnIngredient(dynamic data, Offset globalPosition, double sizeMultiplier) {
     // Use sizeMultiplier to scale the radius (base 2.5)
     // data should be IngredientData
     if (data == null) return;
     
     // Convert to world coordinates
     final worldPosition = screenToWorld(Vector2(globalPosition.dx, globalPosition.dy));
     
     // Optional: Adjust position if the drop was in screen space but game is zoomed/panned.
     // screenToWorld handles camera transform.
     
     // Extract color from data if possible, or random
     Color color = Colors.green;
     String id = 'unknown';
     
     if (data.runtimeType.toString() == 'IngredientData') {
        try {
          final d = data as dynamic;
          color = Color(d.color);
          id = d.id;
        } catch (e) {
          // ignore
        }
     }

     add(IngredientBody(
       initialPosition: worldPosition,
       radius: 2.5 * sizeMultiplier,
       color: color,
       ingredientId: id,
     ));
  }
  
  void clearIngredients() {
    // Remove all IngredientBody components
    children.whereType<IngredientBody>().forEach((body) {
      body.removeFromParent();
    });
  }

  /// Returns a list of ingredient IDs (e.g. 'flour', 'water') currently in the world
  List<String> getCollectedIngredientIds() {
    return children
        .whereType<IngredientBody>()
        .map((body) {
           // We need to map back from color/body to ID? 
           // Or store ID in IngredientBody.
           // Currently IngredientBody has initialPosition and Color.
           // We should store the ID in IngredientBody.
           return body.ingredientId;
        })
        .toList();
  }
  
  void createBoundaries(Rect rect) {
    // Creating a static ground body to anchor joints to
    final groundShape = EdgeShape()
      ..set(Vector2(-100, 50), Vector2(100, 50)); // A flat line at y=50

    final groundBodyDef = BodyDef(type: BodyType.static);
    groundBody = world.createBody(groundBodyDef);
    
    groundBody.createFixture(FixtureDef(groundShape, friction: 0.6));
  }
  
  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (mouseJoint != null) {
      return;
    }
    // Convert screen tap to world coordinates
    final worldPosition = screenToWorld(info.eventPosition.global);
    
    // Spawn ingredient at tap
    add(IngredientBody(initialPosition: worldPosition));
  }

  @override
  void onPanStart(DragStartInfo info) {
    final worldPosition = screenToWorld(info.eventPosition.global);
    
    // Check if we touched an ingredient
    // Use the physics world directly query bodies
    // Or just iterate if the list is small (simple for now)
    
    // world.bodies is not exposed directly on Forge2DWorld, accessing via physicsWorld might work, 
    // or we can iterate components if we tracked them.
    // However, Forge2DGame usually provides access to the underlying world.
    
    // Let's try iterating components that are IngredientBody
    // This is safer in Flame strict mode.
    for (final component in children.whereType<IngredientBody>()) {
      final body = component.body;
      // Check if point is inside
      // We can use the first fixture for simplicity
      if (body.fixtures.isNotEmpty && body.fixtures.first.testPoint(worldPosition)) {
          
          final mouseJointDef = MouseJointDef()
            ..bodyA = groundBody
            ..bodyB = body
            ..frequencyHz = 5.0
            ..dampingRatio = 0.7
            ..collideConnected = false
            ..maxForce = 1000.0 * body.mass;
            
          // target is final in some versions, but usually we set it via the property.
          // If it's final, we use setValues or copyFrom. 
          // Actually in forge2d dart, target is a Vector2, so we can modify it in place?
          // Or if the Setter is missing, we initialize it.
          // Let's assume we can modify it or it's a field. 
          // If 'target' assignment failed, it might be final.
          mouseJointDef.target.setFrom(worldPosition);

          mouseJoint = MouseJoint(mouseJointDef);
          world.createJoint(mouseJoint!);
          break;
      }
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (mouseJoint != null) {
      final worldPosition = screenToWorld(info.eventPosition.global);
      mouseJoint!.setTarget(worldPosition);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (mouseJoint != null) {
      world.destroyJoint(mouseJoint!);
      mouseJoint = null;
    }
  }

  @override
  void onPanCancel() {
     if (mouseJoint != null) {
      world.destroyJoint(mouseJoint!);
      mouseJoint = null;
    }
  }
}
