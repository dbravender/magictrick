import 'dart:math';

//import 'package:dartmcts/net.dart';
import 'package:dartmcts/net.dart';
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
    bool done = false;
    List<double> reward = List.filled(playerCount, 0.0);

    game = game.cloneAndApplyMove(move, null);

    // highest possible score 3 points for correct bid, 2 points for prestige bonus
    const double maxScore = 5.0;

    // hand is over
    if (game.winner != null) {
      done = true;
      for (var p = 0; p < playerCount; p++) {
        reward[p] = game.scores[p]! / maxScore;
      }
    }
    return StepResponse(
      done: done,
      reward: reward,
    );
  }
}
