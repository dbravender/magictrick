import 'dart:convert';
import 'dart:io';

import 'package:magictrick/magictrick.dart';

void main() {
  var game = Game();
  while (game.overallWinner == null) {
    print(game.representation(summary: game.currentPlayer != 0));

    int move = 0;
    if (game.currentPlayer == 0) {
      try {
        stdout.write("move> ");
        var line = stdin.readLineSync(encoding: utf8)!;
        move = int.parse(line);
      } catch (e) {
        print("Invalid move? Exception: $e");
        continue;
      }
    } else {
      move = (game.getMoves()..shuffle()).first;
    }
    game = game.cloneAndApplyMove(move);
  }
  print(game.representation());
}
