import 'package:magictrick/magictrick.dart';
import 'package:test/test.dart';

void main() {
  group('cards', () {
    test('deal', () {
      List<Card> cards = deck();
      expect(cards.length, 56);
    });

    test('getCard', () {
      expect(getCard(7, Suit.hearts),
          equals(Card(id: 31, suit: Suit.hearts, value: 7)));
    });

    test('getWinner - trump wins', () {
      expect(
          getWinner(leadSuit: Suit.clubs, trick: {
            0: getCard(1, Suit.clubs),
            1: getCard(2, Suit.diamonds),
            2: getCard(0, Suit.hearts),
            3: getCard(7, Suit.moons)
          }),
          equals(
              WinningPlayerAndCard(player: 2, card: getCard(0, Suit.hearts))));
    });

    test('getWinner - highest lead card wins', () {
      expect(
          getWinner(leadSuit: Suit.clubs, trick: {
            0: getCard(1, Suit.spades),
            1: getCard(2, Suit.diamonds),
            2: getCard(0, Suit.clubs),
            3: getCard(7, Suit.moons)
          }),
          equals(
              WinningPlayerAndCard(player: 2, card: getCard(0, Suit.clubs))));
    });

    test('getWinner - highest lead card wins', () {
      expect(
          getWinner(leadSuit: Suit.clubs, trick: {
            0: getCard(1, Suit.clubs),
            1: getCard(2, Suit.diamonds),
            2: getCard(0, Suit.clubs),
            3: getCard(7, Suit.moons)
          }),
          equals(
              WinningPlayerAndCard(player: 0, card: getCard(1, Suit.clubs))));
    });
  });
}
