import 'package:app/game/kitchen_game.dart';
import 'package:app/state/discovery_state.dart';
import 'package:app/ui/ingredient_sidebar.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: InfiniKitchenApp()));
}

class InfiniKitchenApp extends StatelessWidget {
  const InfiniKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfiniKitchen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can access the game instance via a GlobalKey or pass a controller
    // For simplicity, we'll let the GameWidget handle its internal state, 
    // but we need a way to pass drag events to it.
    
    // We'll use a GlobalKey<GameWidgetState> if needed, 
    // or just pass a callback to the drag target.
    // Actually, Flame's GameWidget can hold the game instance.
    
    // Let's create the game instance here to pass it to the DragTarget logic.
    final game =  KitchenGame();

    return Scaffold(
      body: Row(
        children: [
          // Left: Playground
          Expanded(
            child: DragTarget<IngredientData>(
              onAcceptWithDetails: (details) {
                 // Convert global drop position to local (game) coordinates
                 final renderBox = context.findRenderObject() as RenderBox;
                 final localPosition = renderBox.globalToLocal(details.offset);
                 
                 // The GameWidget might have its own offset if not full screen or if padded.
                 // Ideally we drop roughly where the mouse is.
                 // Since GameWidget is Expanded, its top-left is 0,0 of this Expanded area? 
                 // No, Row starts at 0,0.
                 
                 // We need to map the drop position to the Game's viewport.
                 // KitchenGame handles screenToWorld.
                 
                 final size = ref.read(quantityProvider);
                 game.spawnIngredient(details.data, details.offset, size);
              },
              builder: (context, candidateData, rejectedData) {
                return GameWidget(game: game);
              },
            ),
          ),
          
          // Right: Sidebar
          const SizedBox(
            width: 300,
            child: IngredientSidebar(),
          ),
        ],
      ),
    );
  }
}
