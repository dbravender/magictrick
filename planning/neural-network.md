# Magic Trick neural network encoding

## General information

* There are 56 cards (0-7 in 7 suits)
* Cards are always ordered from lowest to highest in each hand

## Plan

Train the neural network using perfect information about opponents hands. When playing, multiple simulations will be run using possible hands given the current gamestate.

## Specific implementations

### Version 1

#### Observation

| bits | description |
| ---- | ----------- |
| | **Hands** |
| 56 bits (one per card) | currentPlayer's hand |
| 56 bits (one per card) | (currentPlayer + 1 % 4)'s hand |
| 56 bits (one per card) | (currentPlayer + 2 % 4)'s hand |
| 56 bits (one per card) | (currentPlayer + 3 % 4)'s hand |
| | **Bids** |
| 8 bits (values 0-7) | currentPlayer's bid - no bits set for no bid |
| 8 bits (values 0-7) | ((currentPlayer + 1) % 4)'s bid - no bits set for no bid |
| 8 bits (values 0-7) | ((currentPlayer + 2) % 4)'s bid - no bits set for no bid |
| 8 bits (values 0-7) | ((currentPlayer + 3) % 4)'s bid - no bits set for no bid |
| | **Tricks won** |
| 9 bits | number of tricks won by currentPlayer (8th bit is 8 or more) |
| 9 bits | number of tricks won by ((currentPlayer + 1) % 4) (9th bit is 8 or more) |
| 9 bits | number of tricks won by ((currentPlayer + 2) % 4) (9th bit is 8 or more) |
| 9 bits | number of tricks won by ((currentPlayer + 3) % 4) (9th bit is 8 or more) |
| | **Suits at each index** |
| 14 bits | card in currentPlayer's hand at index is a star |
| 14 bits | card in currentPlayer's hand at index is a spade |
| 14 bits | card in currentPlayer's hand at index is a moon |
| 14 bits | card in currentPlayer's hand at index is a heart |
| 14 bits | card in currentPlayer's hand at index is a diamond |
| 14 bits | card in currentPlayer's hand at index is a club |
| 14 bits | card in currentPlayer's hand at index is a triangle |
| | **Cards played to current trick** |
| 7 bits | suit of 1st card played to trick - unset if not yet played |
| 8 bits | value of 1st card played to trick - unset if not yet played |
| 7 bits | suit of 2nd card played to trick - unset if not yet played |
| 8 bits | value of 2nd card played to trick - unset if not yet played |
| 7 bits | suit of 3rd card played to trick - unset if not yet played |
| 8 bits | value of 3rd card played to trick - unset if not yet played |
| | |
|435 | total input bits|

#### Output

In most card games, the output of the neural network is the ID of the card to play but, in Magic Trick, the player doesn't know which cards are in their hand. Players only know the suits and relative locations of their cards (also encoded in the observation data above). Because of this, the output will be the index of card to play from their hand.

| bits | description |
| ---- | ----------- |
| 14 bits | index of card to play (during playCard state) |
| 14 bits | index of card to bid (during optionalBid state) |
| 1 bit | pass (during optionalBid state) |
| | |
| 29 bits | total output bits |

#### Reward

```dart
StepResponse stepV1(int move) {
    bool done = false;
    List<double> reward = List.filled(playerCount, 0.0);

    game = game.cloneAndApplyMove(move, null);

    // highest possible score 3 points for correct bid (the 2 points for prestige bonus will be "extra")
    const double maxScore = 3.0;

    // lowest possible score -14 points for bidding 0 and taking 14 tricks
    const double minScore = 14.0;

    // hand is over
    if (game.winner != null) {
      done = true;
      for (var p = 0; p < playerCount; p++) {
        if (game.scores[p]! > 0) {
          reward[p] = game.scores[p]! / maxScore;
        } else {
          reward[p] = game.scores[p]! / minScore;
        }
      }
    }
    return StepResponse(
      done: done,
      reward: reward,
    );
  }
```

#### Results

Command run (on https://github.com/davidADSP/SIMPLE/pull/34 revision 68bf1ba7d29d0b2d5d0762dd7e4a3435face07d5):

    docker-compose exec app mpirun -np 6 python3 train.py -r -e remote --entcoeff 0.01 -t .15

Command run on this repo at revision ea6bf6bb18097c41a02f76c145c6c71b6ffbe52f:

    make runtrainingserver

Results playing each of the following models in one match and then alone against random opponents (neural network's best play only - no tree search):

| model | hands_with_highest_score | average_score | wins_against_random | average_score_against_random |
| ----- | ------------------------ | ------------- | ------------------- | ---------------------------- |
| magictrickv1_1468416.tflite | 389 | -0.732 | 534 | -0.684 |
| magictrickv1_1837056.tflite | 390 | -0.706 | 560 | -0.584 |
| magictrickv1_2021376.tflite | 393 | -0.803 | 522 | -0.807 |
| magictrickv1_3065856.tflite | 387 | -0.654 | 520 | -0.688 |
| draw | 29 | 0 | 0 | 0 |

### Version 2

The neural network encoding is the same but the reward for positive scores is different. The player that scores the highest receives a reward of 1. Everyone player's reward is divided by the maximum score and the number of players that received a positive score. This should incentivize plays that score for the current player and block opponents from scoring.

#### Reward

```dart
StepResponse stepV2(int move) {
    bool done = false;
    List<double> reward = List.filled(playerCount, 0.0);

    game = game.cloneAndApplyMove(move, null);

    // the highest score achieved this hand
    int maxScore = -100000;
    int positiveScoringPlayers = 0;
    game.scores.forEach((player, score) {
      if (score > maxScore) {
        maxScore = score;
      }
      if (score > 0) {
        positiveScoringPlayers++;
      }
    });

    // lowest possible score -14 points for bidding 0 and taking 14 tricks
    const double minScore = 14.0;

    // hand is over
    if (game.winner != null) {
      done = true;
      for (var p = 0; p < playerCount; p++) {
        if (game.scores[p]! > 0) {
          reward[p] = game.scores[p]! / maxScore / positiveScoringPlayers;
        } else {
          reward[p] = game.scores[p]! / minScore;
        }
      }
    }
    return StepResponse(
      done: done,
      reward: reward,
    );
  }
```

#### Results

Command run (on https://github.com/davidADSP/SIMPLE/pull/34 revision 68bf1ba7d29d0b2d5d0762dd7e4a3435face07d5):

    docker-compose exec app mpirun -np 6 python3 train.py -r -e remote --entcoeff 0.01 -t .05

The threshold was lowered because the rewards will be much lower.

Command run on this repo at revision 4bca078cfc52a7d4db59562a3a6eafd513e8b0f9:

    make runtrainingserver

### Version 3

Add the number of cards left in hand for current player and suits that players have captured to the observation data. Hopefully this data can be used to learn how to bid better (using the cards left observation data) and achieve the Prestige bonus.

Add the following to the encoding:

| bits | description |
| ---- | ----------- |
| 1 double | Cards remaining in hand / 14 |
| 7 bits (one for each suit) | Suits captured by currentPlayer (for prestige bonus tracking) |

Keep everything else the same.