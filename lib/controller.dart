import 'package:flutter/material.dart';
import 'model.dart';
import 'common_types.dart';

class GameController extends ChangeNotifier {
  ModifiedMemoryGameModel? _model;
  
  ModifiedMemoryGameModel? get model => _model;
  
  void initializeGame({
    required int rows,
    required int cols,
    required int seed,
    required MatchingModeTag matchingMode,
    required TurnOrderTag turnOrder,
  }) {
    try {
      _model = ModifiedMemoryGameModel(
        rows: rows,
        cols: cols,
        seed: seed,
        matchingMode: matchingMode,
        turnOrder: turnOrder,
      );
      notifyListeners();
    } catch (e) {
      // Invalid grid configuration
      _model = null;
      notifyListeners();
    }
  }
  
  bool selectToken(int row, int col) {
    if (_model == null) return false;
    
    bool result = _model!.selectToken(row, col);
    if (result) {
      notifyListeners();
    }
    return result;
  }
  
  bool confirmTurnEnd() {
    if (_model == null) return false;
    
    bool result = _model!.confirmTurnEnd();
    if (result) {
      notifyListeners();
    }
    return result;
  }
  
  // Convenience getters that delegate to model
  Player? get currentPlayer => _model?.currentPlayer;
  Player? get winner => _model?.winner;
  int? getScore(Player player) => _model?.score(player);
  bool get isGameDone => _model?.isGameDone ?? false;
  bool get awaitingConfirmation => _model?.awaitingConfirmation ?? false;
  int? getTokenNumber(int row, int col) => _model?.getTokenNumber(row, col);
  bool isTokenFlipped(int row, int col) => _model?.isTokenFlipped(row, col) ?? false;
  bool isTokenSelected(int row, int col) => _model?.isTokenSelected(row, col) ?? false;
  int get rowCount => _model?.rowCount ?? 0;
  int get colCount => _model?.colCount ?? 0;
}