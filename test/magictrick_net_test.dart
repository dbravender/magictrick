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

    test('encodeSuitsCaptured', () {
      Game game = Game();
      game.state = State.optionalBid;
      var capturedSuits = {Suit.clubs, Suit.diamonds, Suit.spades};
      expect(encodeSuitsCaptured(capturedSuits),
          equals([1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0]));
    });

    group('legalMoves', () {
      test('length', () {
        Game game = Game();
        expect(legalMoves(game).length, equals(29));
      });
      test('bid', () {
        Game game = Game();
        game.state = State.optionalBid;
        game.hands[0] = [];
        expect(legalMoves(game),
            equals(initOneHot(14) + initOneHot(15, value: 14)));
      });

      test('play', () {
        Game game = Game();
        game.state = State.playCard;
        game.hands[0] = [
          getCard(6, Suit.clubs), // 0
          getCard(7, Suit.hearts) // 1
        ];
        game.leadSuit = Suit.hearts;
        // only legal move is the heart which is at location 1
        expect(legalMoves(game),
            equals(initOneHot(14, value: 1) + initOneHot(15)));
      });
    });

    group('encode and decodePlay', () {
      test('length', () {
        Game game = Game();
        expect(legalMoves(game).length, equals(29));
      });

      test('decodePlay playCard', () {
        Game game = Game();
        game.state = State.playCard;
        game.hands[0] = [
          getCard(6, Suit.clubs), // 0
          getCard(7, Suit.hearts), // 1
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
        ];
        game.leadSuit = Suit.hearts;
        // only legal move is the heart which is at location 1
        expect(decodePlay(game, encodeMoves(game, [1])), equals(1));
      });

      test('decodePlay bidCard', () {
        Game game = Game();
        game.state = State.optionalBid;
        game.hands[0] = [
          getCard(6, Suit.clubs), // 0
          getCard(7, Suit.hearts), // 1
          getCard(5, Suit.clubs),
          getCard(4, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
          getCard(1, Suit.clubs),
        ];
        expect(decodePlay(game, encodeMoves(game, [1 + bidOffset])),
            equals(1 + bidOffset));
      });

      test('decoded moves equal encoded moves', () {
        Game game = Game();
        while (game.overallWinner == null) {
          var moves = game.getMoves();
          for (var move in moves) {
            expect(encodePlay(game, move).length, equals(29));
            expect(decodePlay(game, encodePlay(game, move)), equals(move));
          }
          moves.shuffle();
          game = game.cloneAndApplyMove(moves.first, null);
        }
      });
    });

    test('encodeGame', () {
      Game game = Game();
      while (game.overallWinner == null) {
        expect(encodeGame(game).length, equals(472));
        var moves = game.getMoves();
        moves.shuffle();
        game = game.cloneAndApplyMove(moves.first, null);
      }
    });
  });
}
