import 'dart:math';

import 'package:magictrick/magictrick.dart';
import 'package:magictrick/src/magictrick_constraints.dart';
import 'package:test/test.dart';

void main() {
  group('helpers', () {
    List<Card> startHand = [];
    setUp(() {
      startHand = [
        getCard(0, Suit.clubs),
        getCard(0, Suit.spades),
        getCard(1, Suit.spades),
        getCard(1, Suit.clubs),
        getCard(2, Suit.triangles),
        getCard(2, Suit.moons),
        getCard(3, Suit.hearts),
        getCard(3, Suit.moons),
        getCard(4, Suit.stars),
        getCard(5, Suit.triangles),
        getCard(5, Suit.spades),
        getCard(6, Suit.hearts),
        getCard(7, Suit.stars),
        getCard(7, Suit.diamonds),
      ];
    });
    test('findSpotRanges', () {
      expect(
          getSlots(startHand, {}),
          equals([
            Slot(atLeast: 0, atMost: 4, card: getCard(0, Suit.clubs)),
            Slot(atLeast: 0, atMost: 4, card: getCard(0, Suit.spades)),
            Slot(atLeast: 1, atMost: 5, card: getCard(1, Suit.spades)),
            Slot(atLeast: 1, atMost: 5, card: getCard(1, Suit.clubs)),
            Slot(atLeast: 1, atMost: 5, card: getCard(2, Suit.triangles)),
            Slot(atLeast: 1, atMost: 5, card: getCard(2, Suit.moons)),
            Slot(atLeast: 1, atMost: 6, card: getCard(3, Suit.hearts)),
            Slot(atLeast: 2, atMost: 6, card: getCard(3, Suit.moons)),
            Slot(atLeast: 2, atMost: 6, card: getCard(4, Suit.stars)),
            Slot(atLeast: 2, atMost: 7, card: getCard(5, Suit.triangles)),
            Slot(atLeast: 2, atMost: 7, card: getCard(5, Suit.spades)),
            Slot(atLeast: 2, atMost: 7, card: getCard(6, Suit.hearts)),
            Slot(atLeast: 3, atMost: 7, card: getCard(7, Suit.stars)),
            Slot(atLeast: 3, atMost: 7, card: getCard(7, Suit.diamonds))
          ]));

      expect(
          getSlots(startHand, {getCard(3, Suit.hearts)}),
          equals([
            Slot(atLeast: 0, atMost: 2, card: getCard(0, Suit.clubs)),
            Slot(atLeast: 0, atMost: 2, card: getCard(0, Suit.spades)),
            Slot(atLeast: 1, atMost: 3, card: getCard(1, Suit.spades)),
            Slot(atLeast: 1, atMost: 3, card: getCard(1, Suit.clubs)),
            Slot(atLeast: 1, atMost: 3, card: getCard(2, Suit.triangles)),
            Slot(atLeast: 1, atMost: 3, card: getCard(2, Suit.moons)),
            Slot(
                atLeast: 3,
                atMost: 3,
                card: getCard(3, Suit.hearts),
                known: true),
            Slot(atLeast: 3, atMost: 6, card: getCard(3, Suit.moons)),
            Slot(atLeast: 3, atMost: 6, card: getCard(4, Suit.stars)),
            Slot(atLeast: 3, atMost: 7, card: getCard(5, Suit.triangles)),
            Slot(atLeast: 3, atMost: 7, card: getCard(5, Suit.spades)),
            Slot(atLeast: 4, atMost: 7, card: getCard(6, Suit.hearts)),
            Slot(atLeast: 4, atMost: 7, card: getCard(7, Suit.stars)),
            Slot(atLeast: 4, atMost: 7, card: getCard(7, Suit.diamonds))
          ]));

      expect(
          getSlots(
              startHand, {getCard(3, Suit.hearts), getCard(6, Suit.hearts)}),
          equals([
            Slot(atLeast: 0, atMost: 2, card: getCard(0, Suit.clubs)),
            Slot(atLeast: 0, atMost: 2, card: getCard(0, Suit.spades)),
            Slot(atLeast: 1, atMost: 3, card: getCard(1, Suit.spades)),
            Slot(atLeast: 1, atMost: 3, card: getCard(1, Suit.clubs)),
            Slot(atLeast: 1, atMost: 3, card: getCard(2, Suit.triangles)),
            Slot(atLeast: 1, atMost: 3, card: getCard(2, Suit.moons)),
            Slot(
                atLeast: 3,
                atMost: 3,
                card: getCard(3, Suit.hearts),
                known: true),
            Slot(atLeast: 3, atMost: 6, card: getCard(3, Suit.moons)),
            Slot(atLeast: 3, atMost: 6, card: getCard(4, Suit.stars)),
            Slot(atLeast: 3, atMost: 6, card: getCard(5, Suit.triangles)),
            Slot(atLeast: 3, atMost: 6, card: getCard(5, Suit.spades)),
            Slot(
                atLeast: 6,
                atMost: 6,
                card: getCard(6, Suit.hearts),
                known: true),
            Slot(atLeast: 6, atMost: 7, card: getCard(7, Suit.stars)),
            Slot(atLeast: 6, atMost: 7, card: getCard(7, Suit.diamonds))
          ]));
    });
  });
  group('state determination', () {
    List<List<Card>> startHands = [];
    Random randomWithSeed = Random(1);
    setUp(() {
      startHands = [
        [
          getCard(0, Suit.clubs),
          getCard(0, Suit.spades),
          getCard(1, Suit.spades),
          getCard(1, Suit.clubs),
          getCard(2, Suit.triangles),
          getCard(2, Suit.moons),
          getCard(3, Suit.hearts),
          getCard(3, Suit.moons),
          getCard(4, Suit.stars),
          getCard(5, Suit.triangles),
          getCard(5, Suit.spades),
          getCard(6, Suit.hearts),
          getCard(7, Suit.stars),
          getCard(7, Suit.diamonds),
        ],
        [
          getCard(0, Suit.hearts),
          getCard(0, Suit.triangles),
          getCard(0, Suit.diamonds),
          getCard(2, Suit.spades),
          getCard(3, Suit.triangles),
          getCard(4, Suit.moons),
          getCard(5, Suit.stars),
          getCard(5, Suit.hearts),
          getCard(6, Suit.stars),
          getCard(6, Suit.spades),
          getCard(6, Suit.diamonds),
          getCard(7, Suit.hearts),
          getCard(7, Suit.clubs),
          getCard(7, Suit.spades),
        ],
      ];
    });
    test('all cards visible, no shuffling performed', () {
      List<Set<Card>> visibleCards = [
        Set.from(startHands[0]),
        Set.from(startHands[1])
      ];
      var newHands = tradeUnkownCards(startHands, visibleCards, randomWithSeed);
      expect(newHands, equals(startHands));
    });
  });
}
