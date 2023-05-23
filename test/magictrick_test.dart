import 'package:magictrick/magictrick.dart';
import 'package:test/test.dart';

void main() {
  group('cards', () {
    test('deal', () {
      List<Card> cards = deck();
      expect(cards.length, 56);
    });

    test('getCard', () {
      expect(getCard(Suit.hearts, 7),
          equals(Card(id: 31, suit: Suit.hearts, value: 7)));
    });

    test('getWinner - trump wins', () {
      expect(
          getWinner(leadSuit: Suit.clubs, trick: {
            0: getCard(Suit.clubs, 1),
            1: getCard(Suit.diamonds, 2),
            2: getCard(Suit.hearts, 0),
            3: getCard(Suit.moons, 7)
          }),
          equals(
              WinningPlayerAndCard(player: 2, card: getCard(Suit.hearts, 0))));
    });

    test('getWinner - highest lead card wins', () {
      expect(
          getWinner(leadSuit: Suit.clubs, trick: {
            0: getCard(Suit.spades, 1),
            1: getCard(Suit.diamonds, 2),
            2: getCard(Suit.clubs, 0),
            3: getCard(Suit.moons, 7)
          }),
          equals(
              WinningPlayerAndCard(player: 2, card: getCard(Suit.clubs, 0))));
    });

    test('getWinner - highest lead card wins', () {
      expect(
          getWinner(leadSuit: Suit.clubs, trick: {
            0: getCard(Suit.clubs, 1),
            1: getCard(Suit.diamonds, 2),
            2: getCard(Suit.clubs, 0),
            3: getCard(Suit.moons, 7)
          }),
          equals(
              WinningPlayerAndCard(player: 0, card: getCard(Suit.clubs, 1))));
    });
  });
}
