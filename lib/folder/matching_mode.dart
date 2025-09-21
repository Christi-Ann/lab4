import 'dart:math';
import 'common_types.dart';
// This handles stuff related to the grid

class Token {
  final int _value;
  bool _flippedUp;

  Token({required int value}):
    _value = value,
    _flippedUp = false;

  int get value => _value;
  bool get isFlippedUp => _flippedUp;

  void flip() {
    _flippedUp = !_flippedUp;
  }

}

class MatchingMode {
  final int _R;
  final int _C;
  late List<List<Token>> _grid;

  MatchingMode ({
    required int R,
    required int C,
    required int S,
  }):
    _R = R,
    _C = C
  {
    Random rand = Random(S);
    int n = _R * _C;
    int m = n ~/ 2;
    List<int> gridArray = [];
    for (int i = 0; i < m; i++) {
      gridArray.add(i);
      gridArray.add(i);
    }
    for (int i = 0; i < n-1; i++) {
      int k = rand.nextInt(n-i) + i;
      int tmp = gridArray[i];
      gridArray[i] = gridArray[k];
      gridArray[k] = tmp;
    }
    List<List<Token>> _grid = List.generate(
      R,
      (r) => List.generate(
        C, (c) => Token(value: gridArray[r*C + c])
      )
    );
  }

}