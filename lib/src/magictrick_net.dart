import 'dart:math';

import 'package:dartmcts/net.dart';
import 'package:magictrick/magictrick.dart';
import 'package:magictrick/src/magictrick_constraints.dart';

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
  return encodeGameV4(game);
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

List<double> encodeSuitsCaptured(Set<Suit> suitsCaptured) {
  List<double> l = [];
  for (var suit in [
    Suit.clubs,
    Suit.diamonds,
    Suit.hearts,
    Suit.moons,
    Suit.spades,
    Suit.stars,
    Suit.triangles
  ]) {
    l.add(suitsCaptured.contains(suit) ? 1.0 : 0.0);
  }
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

List<double> encodeMoves(Game game, List<int> moves) {
  List<double> l = initOneHot(29);
  for (var move in moves) {
    l[move] = 1;
  }
  return l;
}

List<double> legalMoves(Game game) {
  return encodeMoves(game, game.getMoves());
}

class MoveScore<Move> {
  Move move;
  double score;

  MoveScore(this.move, this.score);

  @override
  String toString() {
    return 'MoveScore(score: $score, move: $move)';
  }
}

List<double> encodePlay(Game game, int move) {
  return encodeMoves(game, [move]);
}

int decodePlay(Game game, List<double> output) {
  var moves = game.getMoves();
  List<MoveScore> moveScore = [];
  for (var move in moves) {
    moveScore.add(MoveScore(move, output[move]));
  }
  moveScore.shuffle(); // shuffle so ties don't always go to the same move
  moveScore.sort((a, b) => a.score.compareTo(b.score));
  int actualMove = moveScore.last.move;
  if (!game.getMoves().contains(actualMove)) {
    throw Exception("illegal move!: ");
  }
  return actualMove;
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
        min(game.tricksTaken[game.currentPlayer! + offset] ?? 0, 8);
    l.addAll(initOneHot(9, value: tricksTaken));
  }
  // suits at each index for the current player
  l.addAll(encodeSuitOrder(game.hands[game.currentPlayer!]));
  // current trick
  for (var offset = 1; offset < 4; offset++) {
    Card? card = game.currentTrick[(game.currentPlayer! + offset) % 4];
    l.addAll(encodeCard(card));
  }
  // legal moves must always be appended to the observation data
  l.addAll(legalMoves(game));
  return l;
}

/// Second encoding
List<double> encodeGameV2(Game game) {
  // uses the same encoding as V1 - only the reward function has changed
  return encodeGameV1(game);
}

/// Third encoding
List<double> encodeGameV3(Game game) {
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
        min(game.tricksTaken[game.currentPlayer! + offset] ?? 0, 8);
    l.addAll(initOneHot(9, value: tricksTaken));
  }
  // suits at each index for the current player
  l.addAll(encodeSuitOrder(game.hands[game.currentPlayer!]));
  // current trick
  for (var offset = 1; offset < 4; offset++) {
    Card? card = game.currentTrick[(game.currentPlayer! + offset) % 4];
    l.addAll(encodeCard(card));
  }
  // cards remaining in hand / 14
  l.add(hands[game.currentPlayer!].length / 14.0);
  l.addAll(encodeSuitsCaptured(game.capturedSuits[game.currentPlayer!]!));
  // legal moves must always be appended to the observation data
  l.addAll(legalMoves(game));
  return l;
}

List<double> encodeValueRanges(List<Card> hand, Set<Card> knownCards) {
  List<double> l = [];
  List<Slot> slots = getSlots(hand, knownCards);
  for (var slot in slots) {
    l.add(slot.atLeast / 7);
    l.add(slot.atMost / 7);
  }
  return l;
}

/// Fourth encoding
List<double> encodeGameV4(Game game) {
  // The idea behind this encoding is to stop sending perfect information
  // to the neural network and instead send information about which cards
  // have been revealed and potential value ranges for cards that have not
  // been revealed
  List<double> l = [];
  // bids
  for (var offset = 0; offset < 4; offset++) {
    // bid bit
    l.add(game.bidCards[game.currentPlayer! + offset]?.value == null ? 0 : 1);
    // bid value divided by 14 to keep it consistent with the tricks won
    // counter
    l.add((game.bidCards[game.currentPlayer! + offset]?.value ?? 0) / 14.0);
    l.add((game.tricksTaken[game.currentPlayer! + offset] ?? 0) / 14.0);
  }
  // suits at each index for all players
  l.addAll(encodeSuitOrder(game.hands[game.currentPlayer!]));
  l.addAll(encodeSuitOrder(game.hands[(game.currentPlayer! + 1) % 4]));
  l.addAll(encodeSuitOrder(game.hands[(game.currentPlayer! + 2) % 4]));
  l.addAll(encodeSuitOrder(game.hands[(game.currentPlayer! + 3) % 4]));
  // lowest and highest possible value for each slot
  l.addAll(
      encodeValueRanges(game.hands[game.currentPlayer!], game.visibleCards));
  l.addAll(encodeValueRanges(
      game.hands[(game.currentPlayer! + 1) % 4], game.visibleCards));
  l.addAll(encodeValueRanges(
      game.hands[(game.currentPlayer! + 2) % 4], game.visibleCards));
  l.addAll(encodeValueRanges(
      game.hands[(game.currentPlayer! + 3) % 4], game.visibleCards));
  // current trick
  for (var offset = 1; offset < 4; offset++) {
    Card? card = game.currentTrick[(game.currentPlayer! + offset) % 4];
    l.addAll(encodeCard(card));
  }
  Set<Card> currentHand = game.hands[0].toSet()..removeAll(game.visibleCards);
  // cards remaining in hand
  l.add(currentHand.length / 14.0);
  l.addAll(encodeSuitsCaptured(game.capturedSuits[game.currentPlayer!]!));
  // legal moves must always be appended to the observation data
  l.addAll(legalMoves(game));
  return l;
}

class MagicTrickNNInterface extends TrainableInterface {
  Game game = Game();
  List<int> startScores = [];
  @override
  int get playerCount => 4;
  @override
  int get currentPlayer => game.currentPlayer!;

  @override
  List<double> legalActions() {
    return legalMoves(game);
  }

  @override
  List<double> observation() {
    return encodeGame(game);
  }

  @override
  StepResponse step(int move) {
    return stepV2(move);
  }

  StepResponse stepV1(int move) {
    bool done = false;
    List<double> reward = List.filled(playerCount, 0.0);

    game = game.cloneAndApplyMove(move, null);

    // highest possible score 3 points for correct bid (the 2 points for prestige bonus will be "extra")
    const double maxScore = 3.0;

    // lowest possible score -14 points for bidding 0 and taking 14 tricks
    const double minScore = 14.0;

    // hand is over
    if (game.winner != null) {
      done = true;
      for (var p = 0; p < playerCount; p++) {
        if (game.scores[p]! > 0) {
          reward[p] = game.scores[p]! / maxScore;
        } else {
          reward[p] = game.scores[p]! / minScore;
        }
      }
    }
    return StepResponse(
      done: done,
      reward: reward,
    );
  }

  StepResponse stepV2(int move) {
    bool done = false;
    List<double> reward = List.filled(playerCount, 0.0);

    game = game.cloneAndApplyMove(move, null);

    // the highest score achieved this hand
    int maxScore = -100000;
    int positiveScoringPlayers = 0;
    game.scores.forEach((player, score) {
      if (score > maxScore) {
        maxScore = score;
      }
      if (score > 0) {
        positiveScoringPlayers++;
      }
    });

    // lowest possible score -14 points for bidding 0 and taking 14 tricks
    const double minScore = 14.0;

    // hand is over
    if (game.winner != null) {
      done = true;
      for (var p = 0; p < playerCount; p++) {
        if (game.scores[p]! > 0) {
          reward[p] = game.scores[p]! / maxScore / positiveScoringPlayers;
        } else {
          reward[p] = game.scores[p]! / minScore;
        }
      }
    }
    return StepResponse(
      done: done,
      reward: reward,
    );
  }
}
