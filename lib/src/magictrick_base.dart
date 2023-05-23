/// Magic Trick is a trick taking game designed by Chris Wray
/// This code is © 2023 by Dan Bravender

import 'package:json_annotation/json_annotation.dart';

part 'magictrick_base.g.dart';

/// 0 - human player, 1 - left player, 2 - top player, 3 - right player
typedef Player = int;

/// Each suit in the game
enum Suit {
  stars,
  spades,
  moons,
  hearts,
  diamonds,
  clubs,
  triangles,
}

const trump = Suit.hearts;

/// Represents a card in the deck
@JsonSerializable()
class Card {
  final int id;
  final int value;
  final Suit suit;

  Card({required this.id, required this.value, required this.suit});

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  operator ==(Object other) {
    if (other is! Card) {
      return false;
    }
    return other.id == id;
  }

  @override
  int get hashCode => Object.hash(suit, value);
}

Map<Suit, Map<int, int>> reverseLookup = {};

/// Maps IDs to cards
Map<int, Card> idToCard = {for (var card in deck()) card.id: card};

/// Get a Card object for the given suit and value
Card getCard(Suit suit, int value) {
  return idToCard[reverseLookup[suit]![value]]!;
}

/// Create a new shuffled copy of the deck
List<Card> deck() {
  List<Card> deck = [];

  /// For the UI and neural network each game element must have a unique ID
  int id = 0;
  for (var suit in Suit.values) {
    reverseLookup[suit] = {};
    for (var value = 0; value <= 7; value++) {
      Card card = Card(
        id: id++,
        value: value,
        suit: suit,
      );
      deck.add(card);
      reverseLookup[card.suit]![card.value] = card.id;
    }
  }
  deck.shuffle();
  return deck;
}

/// Used by the UI to determine which animations should be applied
enum ChangeType {
  /// Moves a card to a player's hand (after a shuffle)
  deal,

  /// Play a card to the trick
  play,

  /// Move tricks in front of the winner
  tricksToWinner,

  /// Cards all moved to the middle of the screen
  shuffle,

  /// Player score changed
  score,

  /// Highlight the referenced card to show it is playable
  showPlayable,

  /// Return previously highlighted cards to their normal state
  hidePlayable,

  /// Wait for the user to tap the screen
  optionalPause,

  /// Highlight the referenced card
  showWinningCard,

  /// Wait for the user to tap the screen
  gameOver,
}

/// Tracks positions to which cards can move
enum Location {
  /// The middle of the screen
  deck,

  /// There are 4 distinct hands 0 - human, 1 - left, 2 - top, 3 - right
  hand,

  /// Referenced player played referenced card to the current trick
  play,

  /// Referenced player's score changed to point value in the Change
  score,

  /// Each player has a pile of tricks they have taken
  tricksTaken,
}

/// Used by the UI to animate cards and other objects
@JsonSerializable()
class Change {
  ChangeType type;

  /// Which Card, Score or other object is being modified
  int objectId;

  /// The Location to which the specified object will move
  Location dest;

  /// This value is used to display the number of tricks taken when drawing tricks
  int tricksTaken;

  /// When animating a score change this is the score before the change
  int startScore;

  /// When animating a score change this is the score after the change
  int endScore;

  /// When a card is played from a hand this is the index of the card in the hand
  int handOffset;

  /// The player to which this change refers
  int player;

  Change(
      {required this.type,
      required this.objectId,
      required this.dest,
      this.tricksTaken = 0,
      this.startScore = 0,
      this.endScore = 0,
      this.handOffset = 0,
      this.player = 0});

  factory Change.fromJson(Map<String, dynamic> json) => _$ChangeFromJson(json);
  Map<String, dynamic> toJson() => _$ChangeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class WinningPlayerAndCard {
  Player player;
  Card card;

  WinningPlayerAndCard({required this.player, required this.card});

  factory WinningPlayerAndCard.fromJson(Map<String, dynamic> json) =>
      _$WinningPlayerAndCardFromJson(json);
  Map<String, dynamic> toJson() => _$WinningPlayerAndCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  operator ==(Object other) {
    if (other is! WinningPlayerAndCard) {
      return false;
    }
    return other.player == player && other.card == card;
  }

  @override
  int get hashCode => Object.hash(card, player);
}

/// Finds the winning card and winning player for the given leadSuit and trick
WinningPlayerAndCard getWinner(
    {required Suit leadSuit, required Map<Player, Card> trick}) {
  Map<Card, Player> cardsToPlayer = {};
  trick.forEach((player, card) {
    cardsToPlayer[card] = player;
  });
  List<Card> cards = List.from(trick.values);
  cards.sort(
      (a, b) => valueForCard(leadSuit, b).compareTo(valueForCard(leadSuit, a)));
  return WinningPlayerAndCard(player: cardsToPlayer[cards[0]]!, card: cards[0]);
}

int valueForCard(Suit leadSuit, Card card) {
  // Hearts is always trump
  if (card.suit == Suit.hearts) {
    return card.value + 100;
  }
  // Led cards are higher than cards of another suit
  if (card.suit == leadSuit) {
    return card.value + 50;
  }
  return card.value;
}
