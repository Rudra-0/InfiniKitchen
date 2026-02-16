import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';
import 'package:app/game/kitchen_game.dart';

void main() {
  testWidgets('Game widget loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InfiniKitchenApp());

    // Verify that the GamePage is present
    expect(find.byType(GamePage), findsOneWidget);
    
    // Verify that the GameWidget is present
    // Note: finding GameWidget specific generic type might require more setup or just find.byType(GameWidget)
    expect(find.byType(GameWidget<KitchenGame>), findsOneWidget);
  });
}
