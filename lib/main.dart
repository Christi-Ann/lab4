import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import 'view.dart';
import 'common_types.dart';

void main(List<String> args) {
  // Parse command line arguments
  if (args.length < 5) {
    // Return immediately with blank screen for invalid arguments
    runApp(const BlankApp());
    return;
  }
  
  try {
    int rows = int.parse(args[0]);
    int cols = int.parse(args[1]);
    int seed = int.parse(args[2]);
    String matchingModeStr = args[3];
    String turnOrderStr = args[4];
    
    // Validate constraints
    if (rows < 2 || rows > 9 || cols < 2 || cols > 9) {
      runApp(const BlankApp());
      return;
    }
    
    // Parse matching mode
    MatchingModeTag? matchingMode;
    switch (matchingModeStr.toLowerCase()) {
      case 'regular':
        matchingMode = MatchingModeTag.regular;
        break;
      case 'extra1':
        matchingMode = MatchingModeTag.extra1;
        break;
      case 'extra2':
        matchingMode = MatchingModeTag.extra2;
        break;
      default:
        runApp(const BlankApp());
        return;
    }
    
    // Parse turn order
    TurnOrderTag? turnOrder;
    switch (turnOrderStr.toLowerCase()) {
      case 'roundrobin':
        turnOrder = TurnOrderTag.roundRobin;
        break;
      case 'untilincorrect':
        turnOrder = TurnOrderTag.untilIncorrect;
        break;
      default:
        runApp(const BlankApp());
        return;
    }
    
    // Check if grid is valid before creating the app
    int tokensPerGroup = _getTokensPerGroup(matchingMode);
    if ((rows * cols) % tokensPerGroup != 0) {
      runApp(const BlankApp());
      return;
    }
    
    runApp(MainApp(
      rows: rows,
      cols: cols,
      seed: seed,
      matchingMode: matchingMode,
      turnOrder: turnOrder,
    ));
  } catch (e) {
    // Invalid arguments, return blank screen
    runApp(const BlankApp());
  }
}

int _getTokensPerGroup(MatchingModeTag matchingMode) {
  switch (matchingMode) {
    case MatchingModeTag.regular:
      return 2;
    case MatchingModeTag.extra1:
    case MatchingModeTag.extra2:
      return 3;
  }
}

class MainApp extends StatelessWidget {
  final int rows;
  final int cols;
  final int seed;
  final MatchingModeTag matchingMode;
  final TurnOrderTag turnOrder;
  
  const MainApp({
    super.key,
    required this.rows,
    required this.cols,
    required this.seed,
    required this.matchingMode,
    required this.turnOrder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = GameController();
        controller.initializeGame(
          rows: rows,
          cols: cols,
          seed: seed,
          matchingMode: matchingMode,
          turnOrder: turnOrder,
        );
        return controller;
      },
      child: const MaterialApp(
        title: 'Modified Memory Game',
        home: GameView(),
      ),
    );
  }
}

class BlankApp extends StatelessWidget {
  const BlankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SizedBox.shrink(),
      ),
    );
  }
}
