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
    test('getSlots', () {
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

    test('getSlots speed', () {
      var start = DateTime.now();
      for (var i = 0; i < 5000; i++) {
        var hand = deck().sublist(0, 14);
        hand.sort();
        getSlots(hand, {});
      }
      var end = DateTime.now();
      expect(end.difference(start), lessThan(Duration(milliseconds: 200)));
    });

    group('state determination', () {
      test('all cards visible, no shuffling performed', () {
        List<List<Card>> hands = [[], [], [], []];
        var deal = deck();
        for (var player in [0, 1, 2, 3]) {
          var hand = deal.sublist(0, 14);
          deal.removeRange(0, 14);
          hand.sort();
          hands[player].addAll(hand);
        }
        Set<Card> visibleCards = Set.from(hands[0])
          ..addAll(hands[1])
          ..addAll(hands[2])
          ..addAll(hands[3]);
        var newHands =
            generatePossibleHands(hands, visibleCards, random: Random());
        expect(newHands, equals(hands));
      });

      test('all cards visible except for one player properly filled', () {
        List<List<Card>> hands = [[], [], [], []];
        var deal = deck();
        for (var player in [0, 1, 2, 3]) {
          var hand = deal.sublist(0, 14);
          deal.removeRange(0, 14);
          hand.sort();
          hands[player].addAll(hand);
        }
        Set<Card> visibleCards = Set.from(hands[0])
          ..addAll(hands[1])
          ..addAll(hands[2]);
        var newHands =
            generatePossibleHands(hands, visibleCards, random: Random());
        expect(newHands, equals(hands));
      });

      test('performance test for different numbers of unspecified cards', () {
        Map<int, Duration> timeForSearch = {};
        for (var knownCards = 0; knownCards < 14; knownCards++) {
          timeForSearch[knownCards] ??= Duration(seconds: 0);
          for (var i = 0; i < 100; i++) {
            var start = DateTime.now();
            List<List<Card>> hands = [[], [], [], []];
            Set<Card> visibleCards = {};
            var deal = deck();
            for (var player in [0, 1, 2, 3]) {
              var hand = deal.sublist(0, 14);
              deal.removeRange(0, 14);
              visibleCards.addAll(hand.sublist(0, knownCards));
              hand.sort();
              hands[player].addAll(hand);
            }
            generatePossibleHands(hands, visibleCards, random: Random());
            var end = DateTime.now();
            timeForSearch[knownCards] =
                timeForSearch[knownCards]! + end.difference(start);
          }
        }
        /*
          0: 0:00:00.038917,
          1: 0:00:00.023183,
          2: 0:00:00.018191,
          3: 0:00:00.018016,
          4: 0:00:00.017931,
          5: 0:00:00.017444,
          6: 0:00:00.291453,
          7: 0:00:00.149885,
          8: 0:00:00.045667,
          9: 0:00:00.046915,
          10: 0:00:00.037971,
          11: 0:00:00.035024,
          12: 0:00:00.034762,
          13: 0:00:00.034568,
        */
        print(timeForSearch);
      });
    });
  });
}
