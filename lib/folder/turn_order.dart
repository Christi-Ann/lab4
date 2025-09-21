import 'common_types.dart';
// This handles stuff related to player fields

class PlayerClass {
  final Player _num;
  late int _score; 

  PlayerClass(this._num){
    _score = 0;
  }

  int get score => _score;

  Player get num => _num;

  void increment() {
    _score++;
  }
}

class TurnOrder {
  final PlayerClass _player1;
  final PlayerClass _player2;
  late PlayerClass _currentPlayer;
  late final Map<Player, PlayerClass> _playerMap;
  
  TurnOrder():
    _player1 = PlayerClass(Player.p1),
    _player2 = PlayerClass(Player.p2)
  {
    _currentPlayer = _player1;
    _playerMap = {Player.p1: _player1, Player.p2: _player2};
  }

  Player get currentPlayer => _currentPlayer.num;

  int score(Player player) {
    return _playerMap[player]?.score ?? 0;
  }

  Player get higherScore => (_player1.score >= _player2.score) ? _player1.num : _player2.num; 

  void nextTurn(bool matchFound) {
    _currentPlayer = (_currentPlayer.num == Player.p1) ? _player2 : _player1;
  }

  void incrementScore() {
    _currentPlayer.increment();
  }
}

class TurnOrder_UntilIncorrect extends TurnOrder {
  @override
  void nextTurn(bool matchFound) {
    if (!matchFound) super.nextTurn(matchFound);
  }
} 