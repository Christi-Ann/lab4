import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import 'common_types.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modified Memory Game'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.model == null) {
            return const Center(
              child: Text(
                'Invalid game configuration',
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildScoreBoard(controller),
                const SizedBox(height: 20),
                _buildCurrentPlayerInfo(controller),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildGameGrid(controller),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(controller),
                const SizedBox(height: 20),
                _buildGameStatus(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreBoard(GameController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Player 1',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Score: ${controller.getScore(Player.p1) ?? 0}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'Player 2',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Score: ${controller.getScore(Player.p2) ?? 0}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayerInfo(GameController controller) {
    if (controller.isGameDone) {
      return Container();
    }
    
    String playerName = controller.currentPlayer == Player.p1 ? 'Player 1' : 'Player 2';
    Color playerColor = controller.currentPlayer == Player.p1 ? Colors.blue : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: playerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: playerColor),
      ),
      child: Text(
        'Current Turn: $playerName',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: playerColor,
        ),
      ),
    );
  }

  Widget _buildGameGrid(GameController controller) {
    return AspectRatio(
      aspectRatio: controller.colCount / controller.rowCount,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.colCount,
            childAspectRatio: 1.0,
          ),
          itemCount: controller.rowCount * controller.colCount,
          itemBuilder: (context, index) {
            int row = index ~/ controller.colCount;
            int col = index % controller.colCount;
            return _buildToken(controller, row, col);
          },
        ),
      ),
    );
  }

  Widget _buildToken(GameController controller, int row, int col) {
    bool isFlipped = controller.isTokenFlipped(row, col);
    bool isSelected = controller.isTokenSelected(row, col);
    int? tokenNumber = controller.getTokenNumber(row, col);
    
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    if (isFlipped) {
      if (isSelected) {
        backgroundColor = Colors.orange;
        textColor = Colors.white;
      } else {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      }
      displayText = tokenNumber?.toString() ?? '';
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.transparent;
      displayText = '';
    }
    
    return Container(
      margin: const EdgeInsets.all(1),
      child: TextButton(
        onPressed: () {
          if (!controller.isGameDone) {
            controller.selectToken(row, col);
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: Colors.black,
              width: isSelected ? 3 : 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(GameController controller) {
    if (controller.isGameDone || !controller.awaitingConfirmation) {
      return Container();
    }
    
    return ElevatedButton(
      onPressed: () {
        controller.confirmTurnEnd();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: const Text(
        'Confirm Turn End',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildGameStatus(GameController controller) {
    if (!controller.isGameDone) {
      return Container();
    }
    
    Player? winner = controller.winner;
    String statusText;
    Color statusColor;
    
    if (winner != null) {
      String winnerName = winner == Player.p1 ? 'Player 1' : 'Player 2';
      statusText = '🎉 $winnerName Wins! 🎉';
      statusColor = winner == Player.p1 ? Colors.blue : Colors.red;
    } else {
      statusText = '🤝 It\'s a Draw! 🤝';
      statusColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}