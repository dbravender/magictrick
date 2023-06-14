/// The game rules for Magic Trick were created by Chris Wray, all rights reserved.
/// This code is © 2023 by Dan Bravender

import 'package:json_annotation/json_annotation.dart';
import 'package:dartmcts/dartmcts.dart';
import 'package:magictrick/src/magictrick_constraints.dart';

part 'magictrick_base.g.dart';

/// 0 - human player, 1 - left player, 2 - top player, 3 - right player
typedef Player = int;

/// Each possible move must have a unique ID for the neural network
/// 0 - 55 card to play (only allowed when state is playCard)
/// 56 - 112 card to bid (only allowed when state is optionalBid)
/// 113 - pass (only allowed when state is optionalBid)
typedef Move = int;
const Move bidOffset = 56;
const Move pass = 113;

/// In the UI card IDs range from 0-56 + 57 for the pass card
const passCardID = 57;

/// When it is a player's turn they must first play a card
/// and then they may bid or pass
enum State {
  playCard,
  optionalBid,
}

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

const Map<Suit, String> suitString = {
  Suit.stars: "★",
  Suit.spades: "♠",
  Suit.moons: "☾",
  Suit.hearts: "♥",
  Suit.diamonds: "♦",
  Suit.clubs: "♣️",
  Suit.triangles: "▲",
};

const trump = Suit.hearts;

/// Represents a card in the deck
@JsonSerializable()
class Card implements Comparable<Card> {
  final int id;
  final int value;
  final Suit suit;

  Card({required this.id, required this.value, required this.suit});

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);

  @override
  String toString() {
    return "$value${suitString[suit]}";
  }

  @override
  operator ==(Object other) {
    if (other is! Card) {
      return false;
    }
    return other.id == id;
  }

  @override
  int compareTo(Card other) {
    return value.compareTo(other.value);
  }

  @override
  int get hashCode => Object.hash(suit, value);
}

Map<Suit, Map<int, int>> reverseLookup = {};

/// Maps IDs to cards
Map<int, Card> idToCard = {for (var card in deck()) card.id: card};

/// Get a Card object for the given suit and value
Card getCard(int value, Suit suit) {
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

/// Used by the UI to determine which animations should be applied between
/// game states
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

  /// Show the player that they captured a new suit
  suitCaptured,

  /// Wait for the user to tap the screen and display the game over dialog
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

  /// Suits the human player has captured
  suits,
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

  /// The suit captured by a player
  Suit? suit;

  /// In Magic Trick since played cards are faceup and unplayed cards (even in
  /// your hand) are face-down we need to know the state of each card
  bool faceup;

  Change(
      {required this.type,
      required this.objectId,
      required this.dest,
      this.tricksTaken = 0,
      this.startScore = 0,
      this.endScore = 0,
      this.handOffset = 0,
      this.player = 0,
      this.suit,
      this.faceup = false});

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

/// Rules engine for Magic Trick
@JsonSerializable()
class Game implements GameState<Move, Player> {
  State state = State.playCard;

  /// hands[0] is the human players hand
  /// AI hands are hands[1-3]
  List<List<Card>> hands = [];

  /// When a card is flipped face up it is added to visibleCards
  Set<Card> visibleCards = {};

  /// When a player has bid the card is added here
  Map<Player, Card> bidCards = {};

  /// List of animations to run since the last game state was displayed
  List<List<Change>> changes = [];

  /// Cards played into the current trick
  Map<Player, Card> currentTrick = {};

  /// Tracks how many tricks each player has taken
  Map<Player, int> tricksTaken = {0: 0, 1: 0, 2: 0, 3: 0};

  /// Which suit was led for the current trick - null at the start of a trick
  Suit? leadSuit;

  /// Tracks scores for each player
  Map<Player, int> scores = {0: 0, 1: 0, 2: 0, 3: 0};

  /// Track which suits were taken for each player
  Map<Player, Set<Suit>> capturedSuits = {0: {}, 1: {}, 2: {}, 3: {}};

  /// Tracks number of times player received prestige bonus for the tie breaker
  Map<Player, int> prestigeCount = {0: 0, 1: 0, 2: 0, 3: 0};

  /// Player whose turn it is
  @override
  Player? currentPlayer = 0;

  /// When set it means the hand has a winner (used for tree search)
  @override
  Player? winner;

  /// When set it means the game is over
  Player? overallWinner;

  /// Player who starts a hand
  int handStarter = 0;

  /// Current game round - 4 rounds are played per game
  int round = 0;

  Game() {
    deal();
  }

  deal() {
    leadSuit = null;
    round += 1;
    tricksTaken = {0: 0, 1: 0, 2: 0, 3: 0};
    visibleCards = {};
    bidCards = {};
    hands = [[], [], [], []];
    capturedSuits = {0: {}, 1: {}, 2: {}, 3: {}};
    state = State.playCard; // always start in the playCard state
    currentPlayer = handStarter;
    handStarter = (handStarter + 1) % 4;
    int dealIndex = changes.length;
    int cardSortingIndex = changes.length + 1;
    changes.addAll([
      [], // deal
      [], // card sorting
    ]);
    List<Card> cards = deck();
    for (int y = 0; y < 14; y++) {
      for (int player = 0; player < 4; player++) {
        var card = cards.removeAt(0);
        hands[player].add(card);
        changes[dealIndex].add(Change(
          type: ChangeType.deal,
          objectId: card.id,
          dest: Location.hand,
          player: player,
          handOffset: y,
        ));
      }
    }
    for (int player = 0; player < 4; player++) {
      hands[player].sort((a, b) => a.value.compareTo(b.value));
      for (int y = 0; y < 14; y++) {
        var card = hands[player][y];
        changes[cardSortingIndex].add(Change(
            type: ChangeType.deal,
            objectId: card.id,
            dest: Location.hand,
            player: player,
            handOffset: y));
      }
    }
    showPlayable();
  }

  /// Creates a completely independent copy of the current game-state
  Game clone() {
    var game = Game();
    game.round = round;
    game.state = state;
    game.visibleCards = Set.from(visibleCards);
    game.currentPlayer = currentPlayer;
    List<List<Card>> newHands = [];
    for (var player = 0; player < 4; player++) {
      newHands.add(List.from(hands[player]));
      game.capturedSuits[player] = Set.from(capturedSuits[player]!);
      if (bidCards[player] != null) {
        game.bidCards[player] = bidCards[player]!;
      }
    }
    game.handStarter = handStarter;
    game.hands = newHands;
    game.tricksTaken = Map.from(tricksTaken);
    game.scores = Map.from(scores);
    game.prestigeCount = Map.from(prestigeCount);
    game.winner = winner;
    game.overallWinner = overallWinner;
    game.leadSuit = leadSuit;
    game.currentTrick = Map.from(currentTrick);
    return game;
  }

  @override
  Game cloneAndApplyMove(Move move, Node<Move, Player>? root) {
    var newGame = clone();
    // reset previous MCTS round winner
    newGame.winner = null;
    newGame.changes = [[]]; // card from player to table
    newGame.currentTrick = Map.from(currentTrick);
    List<Card> currentHand = newGame.hands[currentPlayer!];
    newGame.hands[currentPlayer!] = currentHand;
    if (newGame.state == State.playCard) {
      var card = currentHand.firstWhere((c) => c.id == move);
      // the card that was played is now "visible" in the hand
      newGame.visibleCards.add(card);
      newGame.leadSuit ??= card.suit;
      newGame.changes[0].add(Change(
          type: ChangeType.play,
          dest: Location.play,
          objectId: move,
          player: currentPlayer!));
      newGame.hidePlayable();
      newGame.currentTrick[currentPlayer!] = card;
      if (newGame.bidCards.containsKey(newGame.currentPlayer!)) {
        // current player has already bid - keep the playCard state and go
        // to the next player
        newGame.currentPlayer = (currentPlayer! + 1) % 4;
      } else {
        // the current player has not yet bid - give them the option to bid
        newGame.state = State.optionalBid;
      }
    } else {
      // bid
      if (move == pass) {
        // nothing to do when player passes
      } else {
        var card = currentHand.firstWhere((c) => bidOffset + c.id == move);
        newGame.bidCards[newGame.currentPlayer!] = card;
        // the card that was bid is now "visible" in the hand
        newGame.visibleCards.add(card);
      }
      newGame.state = State.playCard;
      newGame.currentPlayer = (currentPlayer! + 1) % 4;
    }

    // end trick
    if (newGame.currentTrick.length == 4 &&
        newGame.state != State.optionalBid) {
      var trickWinner =
          getWinner(leadSuit: newGame.leadSuit!, trick: newGame.currentTrick);
      var winningCard = trickWinner.card;
      List<Change> revealedSuitChanges = [];
      for (var suit in newGame.currentTrick.values.map((c) => c.suit)) {
        if (!newGame.capturedSuits[trickWinner.player]!.contains(suit)) {
          newGame.capturedSuits[trickWinner.player]!.add(suit);
          revealedSuitChanges.add(Change(
              objectId: winningCard.id,
              dest: Location.suits,
              suit: suit,
              type: ChangeType.suitCaptured,
              player: newGame.currentPlayer ?? 0));
        }
      }
      if (revealedSuitChanges.isNotEmpty) {
        newGame.changes.add(revealedSuitChanges);
      }
      newGame.capturedSuits[trickWinner.player]!
          .addAll(newGame.currentTrick.values.map((c) => c.suit));
      newGame.tricksTaken[trickWinner.player] =
          newGame.tricksTaken[trickWinner.player]! + 1;
      // winner of the trick leads
      newGame.currentPlayer = trickWinner.player;
      newGame.changes.add([
        Change(
            objectId: passCardID,
            type: ChangeType.hidePlayable,
            dest: Location.hand,
            faceup: false),
        Change(
            type: ChangeType.showWinningCard,
            dest: Location.play,
            player: trickWinner.player,
            objectId: winningCard.id),
        Change(
            type: ChangeType.optionalPause, dest: Location.play, objectId: 0),
        Change(
            objectId: winningCard.id,
            dest: Location.play,
            type: ChangeType.hidePlayable,
            player: newGame.currentPlayer ?? 0),
      ]);
      newGame.changes.add([]); // trick back to player
      int offset = newGame.changes.length - 1;
      newGame.currentTrick.forEach((player, card) {
        newGame.changes[offset].add(Change(
            type: ChangeType.tricksToWinner,
            dest: Location.tricksTaken,
            objectId: card.id,
            player: trickWinner.player,
            tricksTaken: newGame.tricksTaken[trickWinner.player]!));
      });
      newGame.currentTrick = {};
      newGame.leadSuit = null;
    }
    if (newGame.visibleCards.length == 56) {
      // All cards have been played
      for (var player in [0, 1, 2, 3]) {
        int points = 0;
        if (newGame.bidCards[player]!.value == newGame.tricksTaken[player]) {
          // successful bid
          points = 3;
          if (newGame.capturedSuits[player]!.length ==
              newGame.bidCards[player]!.value) {
            // prestige bonus
            points += 2;
            newGame.prestigeCount[player] = newGame.prestigeCount[player]! + 1;
          }
        } else {
          // failed bid
          points =
              newGame.bidCards[player]!.value - newGame.tricksTaken[player]!;
          if (points > 0) points *= -1;
        }
        newGame.scores[player] = newGame.scores[player]! + points;
        newGame.changes.add([
          Change(
              type: ChangeType.score,
              dest: Location.score,
              player: player,
              objectId: 0,
              startScore: scores[player]!,
              endScore: newGame.scores[player]!),
        ]);
      }
      List<Player> preTieBreakerWinners = [];
      int highestScore = 1 << 63; // largest negative number possible
      newGame.scores.forEach((player, score) {
        if (score > highestScore) {
          highestScore = score;
        }
      });
      newGame.scores.forEach((player, score) {
        if (score == highestScore) {
          preTieBreakerWinners.add(player);
          newGame.winner = player;
        }
      });

      int highestPrestigeCount = 0;
      for (var player in preTieBreakerWinners) {
        if (newGame.prestigeCount[player]! > highestPrestigeCount) {
          highestPrestigeCount = newGame.prestigeCount[player]!;
        }
      }

      List<Player> winners = [];
      for (var player in preTieBreakerWinners) {
        if (newGame.prestigeCount[player]! == highestPrestigeCount) {
          winners.add(player);
          newGame.winner = player;
        }
      }

      if (newGame.round >= 4) {
        newGame.changes.add([
          Change(type: ChangeType.gameOver, dest: Location.play, objectId: 0),
        ]);
        newGame.overallWinner = newGame.winner;
        return newGame;
      } else {
        newGame.changes.add([
          Change(
            type: ChangeType.shuffle,
            dest: Location.play,
            objectId: 0,
          )
        ]);
        newGame.deal();
      }
    }
    newGame.showPlayable();
    return newGame;
  }

  @override
  List<Move> getMoves() {
    List<Move> moves = [];
    List<Card> playableCards =
        (hands[currentPlayer!].toSet()..removeAll(visibleCards)).toList();
    if (state == State.playCard) {
      if (leadSuit != null) {
        // must follow
        moves = playableCards
            .where((c) => c.suit == leadSuit)
            .map((c) => c.id)
            .toList();
        if (moves.isNotEmpty) {
          return moves;
        }
      }
      return playableCards.map((c) => c.id).toList();
    } else {
      // State.bid
      var moves = playableCards.map((c) => c.id + bidOffset).toList();
      if (playableCards.length == 1) {
        // if the player only has one card left they must bid their last card
        return moves;
      }
      return moves + [pass];
    }
  }

  @override
  Game? determine(GameState? initialState) {
    // FIXME: using actual state so it runs fast in the browser
    return clone();
    // ignore: dead_code
    var newGame = (initialState as Game).clone();
    // see magictrick_constraints.dart to see how possible hands are generated
    newGame.hands = generatePossibleHands(newGame.hands, newGame.visibleCards);
    return newGame;
  }

  hidePlayable() {
    if (changes.isEmpty) {
      changes = [[]];
    }

    List<Change> playableChanges = changes[changes.length - 1];
    for (var card in hands[0]) {
      playableChanges.add(Change(
          objectId: card.id,
          type: ChangeType.hidePlayable,
          dest: Location.hand,
          faceup: visibleCards.contains(card)));
    }
    playableChanges.add(Change(
        objectId: passCardID,
        type: ChangeType.hidePlayable,
        dest: Location.hand,
        faceup: false));
  }

  showPlayable() {
    if (changes.isEmpty) {
      changes = [[]];
    }
    List<Change> playableChanges = changes[changes.length - 1];

    if (currentPlayer == 0) {
      for (var id in getMoves()) {
        if (state == State.optionalBid) {
          id = id - bidOffset;
        }
        playableChanges.add(Change(
            objectId: id, type: ChangeType.showPlayable, dest: Location.hand));
      }
      if (state != State.optionalBid) {
        playableChanges.add(Change(
            objectId: passCardID,
            type: ChangeType.hidePlayable,
            dest: Location.hand,
            faceup: false));
      }
    } else {
      hidePlayable();
    }
  }

  String representation({bool summary = false}) {
    String s = "";
    if (!summary) {
      for (var player in [3, 2, 1, 0]) {
        s += playerHand(player);
      }
    }
    s +=
        "Round: $round\nScores: $scores\nPrestige Bonus Count:$prestigeCount\nbids: $bidCards\nTricks taken: $tricksTaken\nCurrent Trick: $currentTrick\nState: $state\nCurrent Player: $currentPlayer\n";
    return s;
  }

  String playerHand(Player player) {
    String top = "";
    String middle = "";
    String bottom = "";
    var moves = getMoves().toSet();
    int offset = 0;
    if (state == State.optionalBid) {
      offset = bidOffset;
    }
    for (var card in hands[player]) {
      if (currentTrick.values.contains(card)) {
        top += "  P  ";
      } else if (bidCards.values.contains(card)) {
        top += "  B  ";
      } else if (moves.contains(card.id)) {
        top += "  .  ";
      } else {
        top += "     ";
      }
      if (visibleCards.contains(card)) {
        middle += " ${card.value}";
      } else {
        middle += "  ";
      }
      middle += "${suitString[card.suit]}  ";
      if (player == 0 && currentPlayer == 0) {
        if (moves.contains(card.id + offset)) {
          bottom += " ${(card.id + offset).toString().padRight(4)}";
        } else {
          bottom += "     ";
        }
      }
    }
    return "$top\n$middle\n$bottom\n";
  }

  String renderHTML() {
    String s = "<table>";
    for (var player in [3, 2, 1, 0]) {
      String top = "";
      String middle = "";
      String bottom = "";
      for (var card in hands[player]) {
        top += "<td>";
        if (currentTrick.values.contains(card)) {
          top += "played";
        } else if (bidCards.values.contains(card)) {
          top += "bid";
        }
        top += "</td>";
        middle += "<td>";
        if (visibleCards.contains(card)) {
          middle +=
              '<button class="card ${splitSuit(card.suit)}" id="card-${card.id}">${card.value} ${suitString[card.suit]}</button>';
        } else {
          middle +=
              '<button class="card ${splitSuit(card.suit)}" id="card-${card.id}">${suitString[card.suit]}</button>';
        }
        middle += "</td>";
      }
      s += "<tr>$top</tr><tr>$middle</tr><tr>$bottom</tr>";
    }
    s +=
        '</table><button id="card-113">pass</button><button id="advance-game">advance</button><pre>${representation(summary: true)}</pre>';
    return s;
  }

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

String splitSuit(Suit s) {
  return s.toString().split(".")[1];
}
