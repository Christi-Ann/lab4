import 'dart:math';
import 'common_types.dart';

class ModifiedMemoryGameModel {
  final int _rows;
  final int _cols;
  final MatchingModeTag _matchingMode;
  final TurnOrderTag _turnOrder;
  final Random _random;
  
  late List<List<int>> _grid;
  late List<List<bool>> _flippedState;
  Player _currentPlayer = Player.p1;
  int _p1Score = 0;
  int _p2Score = 0;
  List<_TokenPosition> _selectedTokens = [];
  bool _awaitingConfirmation = false;
  bool _foundMatch = false;
  
  ModifiedMemoryGameModel({
    required int rows,
    required int cols,
    required int seed,
    required MatchingModeTag matchingMode,
    required TurnOrderTag turnOrder,
  }) : _rows = rows,
       _cols = cols,
       _matchingMode = matchingMode,
       _turnOrder = turnOrder,
       _random = Random(seed) {
    _initializeGrid();
  }
  
  void _initializeGrid() {
    // Determine the number of tokens per group based on matching mode
    int tokensPerGroup = _getTokensPerGroup();
    int totalTokens = _rows * _cols;
    
    // Check if grid is valid
    if (totalTokens % tokensPerGroup != 0) {
      throw ArgumentError('Invalid grid: total tokens must be divisible by tokens per group');
    }
    
    // Create 1D array with token numbers
    List<int> tokens = [];
    int numberOfGroups = totalTokens ~/ tokensPerGroup;
    
    for (int group = 1; group <= numberOfGroups; group++) {
      for (int i = 0; i < tokensPerGroup; i++) {
        tokens.add(group);
      }
    }
    
    // Apply Fisher-Yates shuffle
    _fisherYatesShuffle(tokens);
    
    // Convert to 2D grid
    _grid = List.generate(_rows, (row) => 
        List.generate(_cols, (col) => tokens[row * _cols + col]));
    
    // Initialize flipped state (all face down initially)
    _flippedState = List.generate(_rows, (row) => 
        List.generate(_cols, (col) => false));
  }
  
  void _fisherYatesShuffle(List<int> array) {
    int n = array.length;
    for (int i = 0; i < n - 1; i++) {
      int k = _random.nextInt(n - i) + i;  // random from i to n-1 inclusive
      // Swap array[i] and array[k]
      int temp = array[i];
      array[i] = array[k];
      array[k] = temp;
    }
  }
  
  int _getTokensPerGroup() {
    switch (_matchingMode) {
      case MatchingModeTag.regular:
        return 2;
      case MatchingModeTag.extra1:
      case MatchingModeTag.extra2:
        return 3;
    }
  }
  
  int _getRequiredSelections() {
    switch (_matchingMode) {
      case MatchingModeTag.regular:
      case MatchingModeTag.extra2:
        return 2;
      case MatchingModeTag.extra1:
        return 3;
    }
  }
  
  Player get currentPlayer => _currentPlayer;
  
  Player? get winner {
    if (!isGameDone) return null;
    if (_p1Score > _p2Score) return Player.p1;
    if (_p2Score > _p1Score) return Player.p2;
    return null; // Draw
  }
  
  int score(Player player) {
    switch (player) {
      case Player.p1:
        return _p1Score;
      case Player.p2:
        return _p2Score;
    }
  }
  
  bool get isGameDone {
    // Game is done when all tokens are flipped up
    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        if (!_flippedState[row][col]) {
          return false;
        }
      }
    }
    return true;
  }
  
  bool selectToken(int row, int col) {
    // Validate coordinates
    if (row < 0 || row >= _rows || col < 0 || col >= _cols) {
      return false;
    }
    
    // Can't select already flipped up tokens
    if (_flippedState[row][col]) {
      return false;
    }
    
    // Can't select if already awaiting confirmation
    if (_awaitingConfirmation) {
      return false;
    }
    
    // Can't select if already selected
    _TokenPosition position = _TokenPosition(row, col);
    if (_selectedTokens.any((token) => token.row == row && token.col == col)) {
      return false;
    }
    
    // Add to selected tokens
    _selectedTokens.add(position);
    _flippedState[row][col] = true;
    
    // Check if we need to process the selection
    _processSelection();
    
    return true;
  }
  
  void _processSelection() {
    if (_matchingMode == MatchingModeTag.extra2) {
      _processExtra2Selection();
    } else {
      _processRegularSelection();
    }
  }
  
  void _processRegularSelection() {
    int required = _getRequiredSelections();
    if (_selectedTokens.length == required) {
      _checkMatch();
    }
  }
  
  void _processExtra2Selection() {
    if (_selectedTokens.length == 2) {
      // Check if first two tokens match
      int token1 = _grid[_selectedTokens[0].row][_selectedTokens[0].col];
      int token2 = _grid[_selectedTokens[1].row][_selectedTokens[1].col];
      
      if (token1 == token2) {
        // Need to select a third token
        return;
      } else {
        // No match, end turn
        _foundMatch = false;
        _awaitingConfirmation = true;
      }
    } else if (_selectedTokens.length == 3) {
      _checkMatch();
    }
  }
  
  void _checkMatch() {
    // Get all token numbers
    List<int> tokenNumbers = _selectedTokens
        .map((pos) => _grid[pos.row][pos.col])
        .toList();
    
    // Check if all tokens have the same number
    bool allMatch = tokenNumbers.every((num) => num == tokenNumbers.first);
    
    if (allMatch) {
      // Found a match
      _foundMatch = true;
      _incrementScore();
      // Tokens remain flipped up
    } else {
      // No match
      _foundMatch = false;
      // Mark for flipping back down
    }
    
    _awaitingConfirmation = true;
  }
  
  void _incrementScore() {
    switch (_currentPlayer) {
      case Player.p1:
        _p1Score++;
        break;
      case Player.p2:
        _p2Score++;
        break;
    }
  }
  
  bool confirmTurnEnd() {
    if (!_awaitingConfirmation) {
      return false;
    }
    
    if (!_foundMatch) {
      // Flip selected tokens back down
      for (_TokenPosition pos in _selectedTokens) {
        _flippedState[pos.row][pos.col] = false;
      }
    }
    
    // Clear selected tokens
    _selectedTokens.clear();
    _awaitingConfirmation = false;
    
    // Determine next player based on turn order
    _determineNextPlayer();
    
    return true;
  }
  
  void _determineNextPlayer() {
    switch (_turnOrder) {
      case TurnOrderTag.roundRobin:
        _switchPlayer();
        break;
      case TurnOrderTag.untilIncorrect:
        if (!_foundMatch) {
          _switchPlayer();
        }
        // If match was found, current player continues
        break;
    }
    _foundMatch = false;
  }
  
  void _switchPlayer() {
    _currentPlayer = _currentPlayer == Player.p1 ? Player.p2 : Player.p1;
  }
  
  int? getTokenNumber(int row, int col) {
    // Validate coordinates
    if (row < 0 || row >= _rows || col < 0 || col >= _cols) {
      return null;
    }
    
    // Return number only if token is flipped up
    if (_flippedState[row][col]) {
      return _grid[row][col];
    }
    
    return null;
  }
  
  int get rowCount => _rows;
  int get colCount => _cols;
  
  // Additional getter methods for view/controller
  bool get awaitingConfirmation => _awaitingConfirmation;
  
  bool isTokenFlipped(int row, int col) {
    if (row < 0 || row >= _rows || col < 0 || col >= _cols) {
      return false;
    }
    return _flippedState[row][col];
  }
  
  bool isTokenSelected(int row, int col) {
    return _selectedTokens.any((token) => token.row == row && token.col == col);
  }
  
  List<_TokenPosition> get selectedTokens => List.unmodifiable(_selectedTokens);
}

class _TokenPosition {
  final int row;
  final int col;
  
  _TokenPosition(this.row, this.col);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TokenPosition && other.row == row && other.col == col;
  }
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}