import 'dart:math';

import 'package:magictrick/magictrick.dart';

/// Initialize and optionally set a value in a one-hot array
/// one-hot arrays are a common way to pass data to a neural network
/// see https://en.wikipedia.org/wiki/One-hot for more information
List<double> initOneHot(int length, {double filler = 0, int? value}) {
  var l = List<double>.filled(length, filler, growable: true);
  if (value != null) {
    l[value] = 1;
  }
  return l;
}

/// Convert the game state to a fixed-length list of doubles
List<double> encodeGame(Game game) {
  return encodeGameV1(game);
}

/// One-hot encode cards by ID
List<double> encodeCards(Set<Card> cards) {
  List<double> l = initOneHot(56);
  for (var card in cards) {
    l[card.id] = 1;
  }
  return l;
}

Map<Suit, int> suitToValue = {
  Suit.clubs: 0,
  Suit.diamonds: 1,
  Suit.hearts: 2,
  Suit.moons: 3,
  Suit.spades: 4,
  Suit.stars: 5,
  Suit.triangles: 6,
};

List<double> encodeCard(Card? card) {
  List<double> l = initOneHot(8);
  if (card == null) {
    l.addAll(initOneHot(7));
    return l;
  }
  l[card.value] = 1;
  l.addAll(initOneHot(7, value: suitToValue[card.suit]));
  return l;
}

List<double> encodeSuitOrder(List<Card> hand) {
  List<double> l = [];
  for (var card in hand) {
    // putting the order here to make sure it is the same
    // for each run
    for (var suit in [
      Suit.clubs,
      Suit.diamonds,
      Suit.hearts,
      Suit.moons,
      Suit.spades,
      Suit.stars,
      Suit.triangles
    ]) {
      l.add(card.suit == suit ? 1.0 : 0.0);
    }
  }
  return l;
}

/// First encoding
List<double> encodeGameV1(Game game) {
  List<double> l = [];
  // hands
  List<Set<Card>> hands = [
    for (var hand in game.hands) hand.toSet()..removeAll(game.visibleCards)
  ];
  for (var offset = 0; offset < 4; offset++) {
    l.addAll(encodeCards(hands[(game.currentPlayer! + offset) % 4]));
  }
  // bids
  for (var offset = 0; offset < 4; offset++) {
    l.addAll(initOneHot(8,
        value: game.bidCards[game.currentPlayer! + offset]?.value));
  }
  // tricks won
  for (var offset = 0; offset < 4; offset++) {
    var tricksTaken =
        max(game.tricksTaken[game.currentPlayer! + offset] ?? 0, 8);
    l.addAll(initOneHot(9, value: tricksTaken));
  }
  // suits at each index for the current player
  l.addAll(encodeSuitOrder(game.hands[game.currentPlayer!]));
  // current trick
  for (var offset = 1; offset < 4; offset++) {
    Card? card = game.currentTrick[(game.currentPlayer! + offset) % 4];
    l.addAll(encodeCard(card));
  }
  return l;
}
