import 'package:magictrick/magictrick.dart';
import 'package:magictrick/src/magictrick_net.dart';
import 'package:test/test.dart';

void main() {
  group('net', () {
    test('initOneHot', () {
      var l = initOneHot(10);
      expect(l.length, equals(10));
      expect(l.every((x) => x == 0.0), equals(true));
      l = initOneHot(3, value: 0);
      expect(l, equals([1.0, 0, 0]));
    });

    test('encodeCards', () {
      for (var card in deck()) {
        var e = encodeCards({card});
        e.asMap().forEach((i, set) {
          if (i == card.id) {
            expect(set, equals(1.0));
          } else {
            expect(set, equals(0.0));
          }
        });
      }
    });

    test('encodeCard', () {
      // no card should set no bits
      expect(
          encodeCard(null),
          equals([
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0
          ]));
      expect(
          encodeCard(getCard(7, Suit.clubs)),
          equals([
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            1.0,
            1.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0
          ]));
      // making sure we are writing in-bounds for each call
      List<Card?> cards = deck();
      for (Card? card in cards) {
        encodeCard(card);
      }
    });

    test('encodeSuitOrder', () {
      var hand = [getCard(7, Suit.diamonds), getCard(2, Suit.stars)];
      expect(
          encodeSuitOrder(hand),
          equals([
            0.0,
            1.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            1.0,
            0.0
          ]));
    });

    test('encodeGame', () {
      Game game = Game();
      while (game.overallWinner == null) {
        expect(encodeGame(game).length, equals(435));
        var moves = game.getMoves();
        moves.shuffle();
        game = game.cloneAndApplyMove(moves.first, null);
      }
    });
  });
}
