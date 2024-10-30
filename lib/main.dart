import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicTacToe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameModeSelection(),
    );
  }
}

class GameModeSelection extends StatelessWidget {
  const GameModeSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Modu Seçimi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TicTacToeGame(isVsComputer: true),
                  ),
                );
              },
              child: const Text('Bilgisayara Karşı Oyna'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TicTacToeGame(isVsComputer: false),
                  ),
                );
              },
              child: const Text('2 Kişilik Oyna'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final bool isVsComputer;
  const TicTacToeGame({Key? key, required this.isVsComputer}) : super(key: key);

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, '');
  bool xTurn = true;
  String winner = '';

  void _makeMove(int index) {
    if (board[index] == '' && winner == '') {
      setState(() {
        board[index] = xTurn ? 'X' : 'O';
        xTurn = !xTurn;
        checkWinner();

        if (widget.isVsComputer && winner == '' && !xTurn) {
          computerMove();
        }
      });
    }
  }

  void computerMove() {
    List<int> emptySpots = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        emptySpots.add(i);
      }
    }

    if (emptySpots.isNotEmpty) {
      final random = Random();
      int computerChoice = emptySpots[random.nextInt(emptySpots.length)];
      // Delay bilgisayar hamlesi için biraz gecikme ekleyebiliriz
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeMove(computerChoice);
      });
    }
  }

  void checkWinner() {
    // Yatay kontroller
    for (int i = 0; i < 9; i += 3) {
      if (board[i] != '' &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) {
        winner = board[i];
        return;
      }
    }

    // Dikey kontroller
    for (int i = 0; i < 3; i++) {
      if (board[i] != '' &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        winner = board[i];
        return;
      }
    }

    // Çapraz kontroller
    if (board[0] != '' && board[0] == board[4] && board[0] == board[8]) {
      winner = board[0];
      return;
    }
    if (board[2] != '' && board[2] == board[4] && board[2] == board[6]) {
      winner = board[2];
      return;
    }

    // Beraberlik kontrolü
    if (!board.contains('')) {
      winner = 'Berabere';
    }
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      xTurn = true;
      winner = '';
    });
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => _makeMove(index),
      child: AnimatedCrossFade(
        firstChild: Container(
          key: const ValueKey('empty'),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.white,
          ),
          child: const Center(
            child: Text(
              '',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        secondChild: Container(
          key: ValueKey(board[index]),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: board[index] == 'X' ? Colors.lightBlueAccent : Colors.pinkAccent,
          ),
          child: Center(
            child: Text(
              board[index],
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        crossFadeState: board[index].isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 300),
        firstCurve: Curves.easeIn,
        secondCurve: Curves.easeOut,
        sizeCurve: Curves.linear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVsComputer ? 'Bilgisayara Karşı' : '2 Kişilik Oyun'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            winner != ''
                ? winner == 'Berabere'
                    ? 'Berabere!'
                    : 'Kazanan: $winner'
                : 'Sıra: ${xTurn ? "X" : "O"}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1, // Kare düzeni sağlamak için
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Kaydırmayı devre dışı bırak
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return buildCell(index);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: resetGame,
            child: const Text('Yeni Oyun'),
          ),
        ],
      ),
    );
  }
}
