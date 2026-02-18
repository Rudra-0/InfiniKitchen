import 'package:app/state/discovery_state.dart';
import 'package:flutter/foundation.dart';

class RecipeLogic {
  
  // Define simple recipes (order independent)
  // Key is sorted list of ingredient IDs joined by '+'
  // Value is result IngredientData
  static final Map<String, IngredientData> _recipes = {
    // 2 Ingredients
    'flour+water': const IngredientData(id: 'dough', name: 'Dough', emoji: '🍞', color: 0xFFF5DEB3),
    'egg+water': const IngredientData(id: 'boiled_egg', name: 'Boiled Egg', emoji: '🥚', color: 0xFFFFF9C4),
    'beef+dough': const IngredientData(id: 'burger', name: 'Burger', emoji: '🍔', color: 0xFF795548),
    
    // 3 Ingredients
    'cheese+dough+tomato': const IngredientData(id: 'pizza', name: 'Pizza', emoji: '🍕', color: 0xFFFFC107),
    'lettuce+oil+tomato': const IngredientData(id: 'salad', name: 'Salad', emoji: '🥗', color: 0xFF4CAF50),
    
    // Potions? (Using Water + X)
    'tomato+water': const IngredientData(id: 'tomato_soup', name: 'Tomato Soup', emoji: '🥣', color: 0xFFF44336), 
    
    // Advanced
    'beef+cheese+dough+tomato': const IngredientData(id: 'cheeseburger', name: 'Cheeseburger', emoji: '🍔', color: 0xFFFFA000),
  };

  /// Checks if the given list of ingredients forms a valid recipe.
  /// Returns the result IngredientData if found, else null.
  static IngredientData? checkRecipe(List<String> ingredientIds) {
    if (ingredientIds.isEmpty) return null;

    // Normalize input: sort alphabetically to match keys
    final sortedIds = List<String>.from(ingredientIds)..sort();
    final key = sortedIds.join('+');
    
    debugPrint('Checking Recipe Key: $key');
    
    return _recipes[key];
  }
}
