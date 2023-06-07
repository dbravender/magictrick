// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magictrick_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Card _$CardFromJson(Map<String, dynamic> json) => Card(
      id: json['id'] as int,
      value: json['value'] as int,
      suit: $enumDecode(_$SuitEnumMap, json['suit']),
    );

Map<String, dynamic> _$CardToJson(Card instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'suit': _$SuitEnumMap[instance.suit]!,
    };

const _$SuitEnumMap = {
  Suit.stars: 'stars',
  Suit.spades: 'spades',
  Suit.moons: 'moons',
  Suit.hearts: 'hearts',
  Suit.diamonds: 'diamonds',
  Suit.clubs: 'clubs',
  Suit.triangles: 'triangles',
};

Change _$ChangeFromJson(Map<String, dynamic> json) => Change(
      type: $enumDecode(_$ChangeTypeEnumMap, json['type']),
      objectId: json['objectId'] as int,
      dest: $enumDecode(_$LocationEnumMap, json['dest']),
      tricksTaken: json['tricksTaken'] as int? ?? 0,
      startScore: json['startScore'] as int? ?? 0,
      endScore: json['endScore'] as int? ?? 0,
      handOffset: json['handOffset'] as int? ?? 0,
      player: json['player'] as int? ?? 0,
      suit: $enumDecodeNullable(_$SuitEnumMap, json['suit']),
    );

Map<String, dynamic> _$ChangeToJson(Change instance) => <String, dynamic>{
      'type': _$ChangeTypeEnumMap[instance.type]!,
      'objectId': instance.objectId,
      'dest': _$LocationEnumMap[instance.dest]!,
      'tricksTaken': instance.tricksTaken,
      'startScore': instance.startScore,
      'endScore': instance.endScore,
      'handOffset': instance.handOffset,
      'player': instance.player,
      'suit': _$SuitEnumMap[instance.suit],
    };

const _$ChangeTypeEnumMap = {
  ChangeType.deal: 'deal',
  ChangeType.play: 'play',
  ChangeType.tricksToWinner: 'tricksToWinner',
  ChangeType.shuffle: 'shuffle',
  ChangeType.score: 'score',
  ChangeType.showPlayable: 'showPlayable',
  ChangeType.hidePlayable: 'hidePlayable',
  ChangeType.optionalPause: 'optionalPause',
  ChangeType.showWinningCard: 'showWinningCard',
  ChangeType.suitCaptured: 'suitCaptured',
  ChangeType.gameOver: 'gameOver',
};

const _$LocationEnumMap = {
  Location.deck: 'deck',
  Location.hand: 'hand',
  Location.play: 'play',
  Location.score: 'score',
  Location.tricksTaken: 'tricksTaken',
  Location.suits: 'suits',
};

WinningPlayerAndCard _$WinningPlayerAndCardFromJson(
        Map<String, dynamic> json) =>
    WinningPlayerAndCard(
      player: json['player'] as int,
      card: Card.fromJson(json['card'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WinningPlayerAndCardToJson(
        WinningPlayerAndCard instance) =>
    <String, dynamic>{
      'player': instance.player,
      'card': instance.card,
    };

Game _$GameFromJson(Map<String, dynamic> json) => Game()
  ..state = $enumDecode(_$StateEnumMap, json['state'])
  ..hands = (json['hands'] as List<dynamic>)
      .map((e) => (e as List<dynamic>)
          .map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList())
      .toList()
  ..visibleCards = (json['visibleCards'] as List<dynamic>)
      .map((e) => Card.fromJson(e as Map<String, dynamic>))
      .toSet()
  ..bidCards = (json['bidCards'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), Card.fromJson(e as Map<String, dynamic>)),
  )
  ..changes = (json['changes'] as List<dynamic>)
      .map((e) => (e as List<dynamic>)
          .map((e) => Change.fromJson(e as Map<String, dynamic>))
          .toList())
      .toList()
  ..currentTrick = (json['currentTrick'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), Card.fromJson(e as Map<String, dynamic>)),
  )
  ..tricksTaken = (json['tricksTaken'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), e as int),
  )
  ..leadSuit = $enumDecodeNullable(_$SuitEnumMap, json['leadSuit'])
  ..scores = (json['scores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), e as int),
  )
  ..capturedSuits = (json['capturedSuits'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k),
        (e as List<dynamic>).map((e) => $enumDecode(_$SuitEnumMap, e)).toSet()),
  )
  ..prestigeCount = (json['prestigeCount'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(int.parse(k), e as int),
  )
  ..currentPlayer = json['currentPlayer'] as int?
  ..winner = json['winner'] as int?
  ..overallWinner = json['overallWinner'] as int?
  ..handStarter = json['handStarter'] as int
  ..round = json['round'] as int;

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'state': _$StateEnumMap[instance.state]!,
      'hands': instance.hands,
      'visibleCards': instance.visibleCards.toList(),
      'bidCards': instance.bidCards.map((k, e) => MapEntry(k.toString(), e)),
      'changes': instance.changes,
      'currentTrick':
          instance.currentTrick.map((k, e) => MapEntry(k.toString(), e)),
      'tricksTaken':
          instance.tricksTaken.map((k, e) => MapEntry(k.toString(), e)),
      'leadSuit': _$SuitEnumMap[instance.leadSuit],
      'scores': instance.scores.map((k, e) => MapEntry(k.toString(), e)),
      'capturedSuits': instance.capturedSuits.map((k, e) =>
          MapEntry(k.toString(), e.map((e) => _$SuitEnumMap[e]!).toList())),
      'prestigeCount':
          instance.prestigeCount.map((k, e) => MapEntry(k.toString(), e)),
      'currentPlayer': instance.currentPlayer,
      'winner': instance.winner,
      'overallWinner': instance.overallWinner,
      'handStarter': instance.handStarter,
      'round': instance.round,
    };

const _$StateEnumMap = {
  State.playCard: 'playCard',
  State.optionalBid: 'optionalBid',
};
