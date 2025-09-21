import 'common_types.dart';
import 'turn_order.dart';
import 'matching_mode.dart';

class ModifiedMemoryGameModel {
  final TurnOrder _playerHandler;
  final MatchingMode _gridHandler;

  ModifiedMemoryGameModel ({
    required TurnOrder playerHandler,
    required MatchingMode gridHandler
  }):
    _playerHandler = playerHandler,
    _gridHandler = gridHandler;

  Player get currentPlayer => _playerHandler.currentPlayer;

  int score(Player player) {
    return _playerHandler.score(player);
  }

  Player? get winner => this.isGameDone ? _playerHandler.higherScore : null;

  bool get isGameDone => true; // TODO
}
