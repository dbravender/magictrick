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
  ChangeType.gameOver: 'gameOver',
};

const _$LocationEnumMap = {
  Location.deck: 'deck',
  Location.hand: 'hand',
  Location.play: 'play',
  Location.score: 'score',
  Location.tricksTaken: 'tricksTaken',
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
