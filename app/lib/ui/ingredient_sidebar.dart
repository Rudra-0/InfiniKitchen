import 'package:app/game/kitchen_game.dart';
import 'package:app/logic/recipe_logic.dart';
import 'package:app/state/discovery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IngredientSidebar extends ConsumerWidget {
  final KitchenGame game;

  const IngredientSidebar({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(discoveryProvider);
    final currentQuantity = ref.watch(quantityProvider);

    return Container(
      width: 300,
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Pantry',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (val) {
               // TODO: Filter logic
            },
          ),
          const SizedBox(height: 16),
          
          // Quantity Slider
          Text('Quantity: ${currentQuantity.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white)),
          Slider(
            value: currentQuantity,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            onChanged: (val) => ref.read(quantityProvider.notifier).setQuantity(val),
          ),
          const Divider(color: Colors.grey),

          // Ingredient Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Draggable<IngredientData>(
                  data: ingredient,
                  feedback: _IngredientIcon(ingredient: ingredient, isDragging: true),
                  childWhenDragging: _IngredientIcon(ingredient: ingredient, opacity: 0.3),
                  child: _IngredientIcon(ingredient: ingredient),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mix Button
          SizedBox(
            width: double.infinity,
            child: FloatingActionButton.extended(
              onPressed: () {
                final ids = game.getCollectedIngredientIds();
                if (ids.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add ingredients first!')),
                  );
                  return;
                }
                
                final result = RecipeLogic.checkRecipe(ids);
                
                if (result != null) {
                  // Unlock discovery
                  ref.read(discoveryProvider.notifier).unlock(result);
                  
                  // Clear and spawn result
                  game.clearIngredients();
                  game.spawnIngredient(result, const Offset(0,0), 1.5); // centered relative to world 0,0 approx
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Discovered: ${result.name} ${result.emoji}!'), backgroundColor: Colors.green),
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No recipe found.'), backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.science),
              label: const Text('MIX'),
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientIcon extends StatelessWidget {
  final IngredientData ingredient;
  final bool isDragging;
  final double opacity;

  const _IngredientIcon({
     required this.ingredient, 
     this.isDragging = false,
     this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: isDragging ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isDragging ? [const BoxShadow(color: Colors.black26, blurRadius: 10)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(ingredient.emoji, style: const TextStyle(fontSize: 32)),
             const SizedBox(height: 4),
             Text(
               ingredient.name, 
               style: const TextStyle(color: Colors.white70, fontSize: 10),
               textAlign: TextAlign.center,
               overflow: TextOverflow.ellipsis,
             ),
          ],
        ),
      ),
    );
  }
}
