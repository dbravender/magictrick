import 'dart:convert';
import 'dart:io';

import 'package:dartmcts/dartmcts.dart';
import 'package:magictrick/magictrick.dart';

void main() {
  bool humanPlay = (Platform.environment["HUMAN"] ?? "true") == "true";
  var game = Game();
  Map<int, List<Duration>> times = {};
  while (game.overallWinner == null) {
    print(game.representation(summary: game.currentPlayer != 0));

    int move = 0;

    if (game.currentPlayer == 0 && humanPlay) {
      try {
        stdout.write("move> ");
        var line = stdin.readLineSync(encoding: utf8)!;
        move = int.parse(line);
        game = game.cloneAndApplyMove(move, null);
      } catch (e) {
        print("Invalid move? Exception: $e");
        continue;
      }
    } else {
      var start = DateTime.now();
      var result = MCTS<Player, Move>(gameState: game)
          .getSimulationResult(actualMoves: game.getMoves());
      game = game.cloneAndApplyMove(result.move!, null);
      var end = DateTime.now();
      var duration = end.difference(start);
      if (duration > Duration(milliseconds: 100)) {
        if (times[game.visibleCards.length] == null) {
          times[game.visibleCards.length] = [];
        }
        times[game.visibleCards.length]!.add(duration);
      }
    }
  }
  print(game.representation());
  times.keys
      .map((key) => times[key]!.reduce((x, y) => x + y))
      .toList()
      .asMap()
      .forEach((key, value) {
    print("$key\t$value");
  });
}
