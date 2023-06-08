@JS()
library static_interop;

import 'dart:html';

import 'package:dartmcts/dartmcts.dart';
import 'package:js/js.dart';
import 'package:magictrick/magictrick.dart';

Map<Suit, String> suitToColor = {
  Suit.clubs: "green",
  Suit.diamonds: "blue",
  Suit.hearts: "red",
  Suit.moons: "purple",
  Suit.spades: "black",
  Suit.triangles: "orange",
};

@JS('render')
external void render(dynamic str);

void enableValidMoves(Game game) {
  var offset = 0;

  if (game.state == State.optionalBid) {
    offset = bidOffset;
  }

  for (var cardID in deck().map((c) => c.id).toList() + [113]) {
    var b = querySelector('#card-$cardID')! as ButtonElement;
    b.disabled = true;
  }

  game.getMoves().forEach((cardID) {
    if (cardID != 113) {
      cardID -= offset;
    }
    var b = querySelector('#card-$cardID')! as ButtonElement;
    b.disabled = false;
  });

  var b = querySelector('#advance-game')! as ButtonElement;
  b.disabled = true;
  if (game.currentPlayer != 0) {
    b.disabled = false;
    querySelector('#advance-game')!.addEventListener('click', (event) {
      advanceGame(game);
    });
  }
}

void showState(Game game) {
  querySelector('#game')!.innerHtml = game.renderHTML();
  for (var cardID in deck().map((c) => c.id).toList() + [113]) {
    querySelector('#card-$cardID')!.addEventListener('click', (event) {
      var offset = 0;
      if (game.state == State.optionalBid && cardID != 113) {
        offset = bidOffset;
      }
      game = game.cloneAndApplyMove(cardID + offset, null);
      print(cardID);
      showState(game);
    });
  }
  enableValidMoves(game);
}

advanceGame(Game game) {
  if (game.currentPlayer != 0) {
    var result = MCTS(gameState: game)
        .getSimulationResult(actualMoves: game.getMoves(), iterations: 1);
    game = game.cloneAndApplyMove(result.move!, null);
    showState(game);
  }
}

void main() {
  var game = Game();
  showState(game);
}
