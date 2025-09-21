import 'package:flutter_test/flutter_test.dart';
import 'package:cs150lab04/tester.dart';
import 'package:cs150lab04/common_types.dart';

void main() {
  group('Tester Module Tests', () {
    test('make function creates valid regular mode model', () {
      final model = make(MatchingModeTag.regular, TurnOrderTag.roundRobin);
      
      expect(model.rowCount, greaterThan(0));
      expect(model.colCount, greaterThan(0));
      expect(model.currentPlayer, Player.p1);
      expect(model.score(Player.p1), 0);
      expect(model.score(Player.p2), 0);
      expect(model.isGameDone, false);
      expect(model.winner, null);
    });

    test('make function creates valid extra1 mode model', () {
      final model = make(MatchingModeTag.extra1, TurnOrderTag.untilIncorrect);
      
      expect(model.rowCount, greaterThan(0));
      expect(model.colCount, greaterThan(0));
      expect(model.currentPlayer, Player.p1);
      expect(model.score(Player.p1), 0);
      expect(model.score(Player.p2), 0);
      expect(model.isGameDone, false);
      expect(model.winner, null);
    });

    test('make function creates valid extra2 mode model', () {
      final model = make(MatchingModeTag.extra2, TurnOrderTag.roundRobin);
      
      expect(model.rowCount, greaterThan(0));
      expect(model.colCount, greaterThan(0));
      expect(model.currentPlayer, Player.p1);
      expect(model.score(Player.p1), 0);
      expect(model.score(Player.p2), 0);
      expect(model.isGameDone, false);
      expect(model.winner, null);
    });

    test('make function works with all turn order combinations', () {
      final combinations = [
        [MatchingModeTag.regular, TurnOrderTag.roundRobin],
        [MatchingModeTag.regular, TurnOrderTag.untilIncorrect],
        [MatchingModeTag.extra1, TurnOrderTag.roundRobin],
        [MatchingModeTag.extra1, TurnOrderTag.untilIncorrect],
        [MatchingModeTag.extra2, TurnOrderTag.roundRobin],
        [MatchingModeTag.extra2, TurnOrderTag.untilIncorrect],
      ];

      for (final combo in combinations) {
        final model = make(combo[0] as MatchingModeTag, combo[1] as TurnOrderTag);
        expect(model, isNotNull);
        expect(model.currentPlayer, Player.p1);
      }
    });
  });
}