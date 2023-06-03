import 'dart:math';

import 'package:magictrick/magictrick.dart';

/// The game rules for Magic Trick were created by Chris Wray, all rights reserved.
/// This code is © 2023 by Dan Bravender

/// Many algorithms that select moves run hundreds to thousands of simulations
/// in order to find the "best" move. A generic constraint solver to determine
/// legal potential hands from scratch might have to backtrack a lot which
/// would be too slow to run that many times to get a move so I'm writing
/// a game-specific algorithm which trades possible cards in-place between
/// players.

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
/// 3. For each set of players randomly trade cards that "overlap"
/// 4. Update possible max and min values based on traded cards.
/// 5. Repeat 3 until all players and cards have been considered for swapping

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
    return "Slot(atLeast: $atLeast, atMost: $atMost, card: $card)";
  }

  @override
  int get hashCode => Object.hash(atLeast, atMost, card);

  @override
  bool operator ==(Object other) {
    if (other is! Slot) {
      return false;
    }
    return atLeast == other.atLeast &&
        atMost == other.atMost &&
        other.card == card;
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

List<List<Card>> tradeUnkownCards(
    List<List<Card>> hands, List<Set<Card>> knownCards,
    [Random? random]) {
  random ??= Random();

  List<List<Card>> newHands = [
    for (var hand in hands) List.from(hand)
  ]; // deep copy hands
  // TODO
  // 1. Randomly select cards that have an overlapping range and consider
  //    swapping them
  // 2. Update the slots that are affected by the new known card value
  return newHands;
}
