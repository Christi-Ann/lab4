import 'model.dart';
import 'common_types.dart';

ModifiedMemoryGameModel make(MatchingModeTag matchingModeTag, TurnOrderTag turnOrderTag) {
  // Default configuration for testing
  int rows = 2;
  int cols = 3;
  int seed = 42;
  
  // Adjust grid size based on matching mode to ensure valid configuration
  switch (matchingModeTag) {
    case MatchingModeTag.regular:
      // Need even number of tokens for pairs
      rows = 2;
      cols = 3; // 6 tokens = 3 pairs
      break;
    case MatchingModeTag.extra1:
    case MatchingModeTag.extra2:
      // Need multiple of 3 tokens for triplets
      rows = 2;
      cols = 3; // 6 tokens = 2 triplets
      break;
  }
  
  return ModifiedMemoryGameModel(
    rows: rows,
    cols: cols,
    seed: seed,
    matchingMode: matchingModeTag,
    turnOrder: turnOrderTag,
  );
}