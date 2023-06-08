import 'package:constraint_solver/constraint_solver.dart';

import 'package:magictrick/magictrick.dart';

/// The game rules for Magic Trick were created by Chris Wray, all rights reserved.
/// This code is © 2023 by Dan Bravender

/// Many algorithms that select moves run hundreds to thousands of simulations
/// in order to find the "best" move. A generic constraint solver to determine
/// legal potential hands from scratch will have to backtrack a lot which
/// will be too slow to run so constraints are relaxed. This means the hands
/// might be in the wrong order and multiple players might have the same card
/// in some simulations. It's better than letting the AI cheat.

/// 1. Act on a copy of the current game state
/// 2. Find possible min and max values for each card
///    We know that the maximum value of a card has to decrement by one each
///    time we see a suit repeated. When counting from the left side the
///    minimum value has to increment by one under the same conditions.
///    Example:
///        ♣️ ♠ ♠ ♣️ ▲ ☾ ♥ ☾ ★ ▲ ♠ ♥ ★ ♦
///        4 4 5 5 5 5 6 6 6 7 7 7 7 7 MAX
///        0 0 1 1 1 1 1 2 2 2 2 2 3 3 MIN
///    Known value example:
///                    3
///        ♣️ ♠ ♠ ♣️ ▲ ☾ ♥ ☾ ★ ▲ ♠ ♥ ★ ♦
///        2 2 3 3 3 3 3 6 6 7 7 7 7 7 MAX
///        0 0 1 1 1 1 3 3 3 3 3 4 4 4 MIN
/// 3. Convert this data into constraints
/// 4. Send constraints to a general CSP and get possible hands

/// There has to be a way to create constraints across players as well
/// ♦  ♦  ▲  ♥  ★  ▲  ♥  ♠  ☾  ♦  ★  ♣️  ♠  ☾
/// ▲  ☾  ☾  ☾  ♠  ♥  ♦  ♣️  ♥  ▲  ♠  ♣️  ♥  ▲
/// ♠  ♥  ♠  ♥  ♠  ♣️  ♦  ▲  ☾  ♦  ★  ☾  ♦  ♠
/// ★  ♣️  ♣️  ♦  ♣️  ★  ★  ☾  ▲  ★  ▲  ♣️  ♥  ★

class Slot {
  int atLeast;
  int atMost;
  Card card;
  bool known;

  Slot(
      {required this.atLeast,
      required this.atMost,
      required this.card,
      this.known = false});

  @override
  String toString() {
    return "Slot(atLeast: $atLeast, atMost: $atMost, card: $card, known: $known)";
  }

  @override
  int get hashCode => Object.hash(atLeast, atMost, card);

  @override
  bool operator ==(Object other) {
    if (other is! Slot) {
      return false;
    }
    return other.atLeast == atLeast &&
        other.atMost == atMost &&
        other.card == card &&
        other.known == known;
  }

  Slot copy() {
    return Slot(atLeast: atLeast, atMost: atMost, card: card, known: known);
  }
}

/// Find the highest and lowest possible value for each card in the given hand
List<Slot> getSlots(List<Card> hand, Set<Card> knownCards) {
  Set<Suit> seenSuits = {};
  List<Slot> slots = [];
  int currentMin = 0;
  for (var card in hand) {
    if (seenSuits.contains(card.suit)) {
      // each time we see a suit we've already seen we increment the minimum
      // possible value for the next set of cards
      currentMin++;
      seenSuits = {card.suit};
    }
    bool known = knownCards.contains(card);
    if (known) {
      // we know the exact value of this
      if (card.value > currentMin) {
        seenSuits = {card.suit};
      }
      currentMin = card.value;
    }
    slots.add(Slot(card: card, atLeast: currentMin, atMost: 0, known: known));
    seenSuits.add(card.suit);
  }
  int currentMax = 7;
  int slotIndex = slots.length;
  seenSuits = {};
  for (var card in hand.reversed) {
    slotIndex--;
    if (seenSuits.contains(card.suit)) {
      seenSuits = {card.suit};
      currentMax--;
    }
    if (knownCards.contains(card)) {
      if (card.value < currentMax) {
        seenSuits = {card.suit};
      }
      currentMax = card.value;
    }
    assert(slots[slotIndex].card == card);
    assert(currentMax >= 0);
    slots[slotIndex].atMost = currentMax;
    seenSuits.add(card.suit);
  }
  return slots;
}

List<Card> possibleCards(Slot slot, Set<Card> visibleCards) {
  List<Card> r = [];
  if (slot.known) {
    return [slot.card];
  }
  for (var value = slot.atLeast; value <= slot.atMost; value++) {
    var card = getCard(value, slot.card.suit);
    if (visibleCards.contains(card)) continue;
    r.add(card);
  }
  r.shuffle();
  return r;
}

List<List<Card>> generatePossibleHands(
    List<List<Card>> hands, Set<Card> visibleCards) {
  List<List<Slot>> slots = [[], [], [], []];
  for (var player in [0, 1, 2, 3]) {
    slots[player] = getSlots(hands[player], visibleCards);
  }

  var variables = List.generate(56, (x) => x);

  Map<int, List<Card>> domains = {};
  int index = 0;

  for (var slot in slots) {
    for (var s in slot) {
      domains[index++] = possibleCards(s, visibleCards);
    }
  }

  var csp = CSP<int, Card>(variables, domains);
  if (visibleCards.length / 4 > 7) {
    // allow repeated cards and non-increasing cards if there are 5 or fewer
    // cards revealed - otherwise it can take minutes to get a valid set of
    // hands
    // TODO: make sure the game engine works with multiple copies of the same
    // card
    // TODO: optimize further (if possible)
    csp.addConstraint(Distinct(variables));
    csp.addConstraint(IncreasingValue(variables));
  }

  var result = csp.backtrackingSearch();
  assert(result != null);

  List<List<Card>> newHands = [[], [], [], []];
  for (var player in [0, 1, 2, 3]) {
    int offset = (player * 14);
    for (var i = 0; i < 14; i++) {
      newHands[player].add(result![offset + i]!);
    }
  }
  return newHands;
}

class Distinct extends Constraint<int, Card> {
  Distinct(super.variables);

  @override
  bool isSatisfied(Map<int, Card> assignment) {
    return Set.from(assignment.values).length == assignment.length;
  }
}

class IncreasingValue extends Constraint<int, Card> {
  IncreasingValue(super.variables);

  @override
  bool isSatisfied(Map<int, Card> assignment) {
    for (var player in [0, 1, 2, 3]) {
      int currentValue = 0;
      int offset = (player * 14);
      for (var i = 0; i < 14; i++) {
        var card = assignment[offset + i];
        if (card == null) {
          continue;
        }
        if (card.value < currentValue) {
          return false;
        }
        currentValue = card.value;
      }
    }

    return true;
  }
}
