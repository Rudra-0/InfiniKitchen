import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple model for an Ingredient
class IngredientData {
  final String id;
  final String name;
  final String emoji; // For UI display
  final int color;    // Hex color for physics body

  const IngredientData({
    required this.id,
    required this.name, 
    required this.emoji,
    required this.color,
  });
}

// Initial Basic Ingredients
const defaultIngredients = [
  IngredientData(id: 'water', name: 'Water', emoji: '💧', color: 0xFF2196F3),
  IngredientData(id: 'flour', name: 'Flour', emoji: '🌾', color: 0xFFFFF59D), // Pale Yellow
  IngredientData(id: 'egg', name: 'Egg', emoji: '🥚', color: 0xFFFFE082),   // Amber
  IngredientData(id: 'tomato', name: 'Tomato', emoji: '🍅', color: 0xFFF44336),
  IngredientData(id: 'cheese', name: 'Cheese', emoji: '🧀', color: 0xFFFFC107),
  IngredientData(id: 'lettuce', name: 'Lettuce', emoji: '🥬', color: 0xFF4CAF50),
  IngredientData(id: 'beef', name: 'Beef', emoji: '🥩', color: 0xFF795548), // Brown
  IngredientData(id: 'oil', name: 'Oil', emoji: '🛢️', color: 0xFFFFEB3B),    // Yellow
];

// Notifier to manage the list of unlocked ingredients
class DiscoveryNotifier extends Notifier<List<IngredientData>> {
  @override
  List<IngredientData> build() {
    return defaultIngredients;
  }

  void unlock(IngredientData ingredient) {
    if (!state.any((i) => i.id == ingredient.id)) {
      state = [...state, ingredient];
    }
  }
}

final discoveryProvider = NotifierProvider<DiscoveryNotifier, List<IngredientData>>(DiscoveryNotifier.new);

// Notifier for the Quantity/Size slider (1.0 to 5.0)
class QuantityNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  void setQuantity(double value) {
    state = value;
  }
}

final quantityProvider = NotifierProvider<QuantityNotifier, double>(QuantityNotifier.new);
