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
| 8 bits (values 0-7) | (currentPlayer + 1 % 4)'s bid - no bits set for no bid |
| 8 bits (values 0-7) | (currentPlayer + 2 % 4)'s bid - no bits set for no bid |
| 8 bits (values 0-7) | (currentPlayer + 3 % 4)'s bid - no bits set for no bid |
| | **Tricks won** |
| 8 bits | number of tricks won by currentPlayer (8th bit is 8 or more) |
| 8 bits | number of tricks won by (currentPlayer + 1 % 4) (8th bit is 8 or more) |
| 8 bits | number of tricks won by (currentPlayer + 2 % 4) (8th bit is 8 or more) |
| 8 bits | number of tricks won by (currentPlayer + 3 % 4) (8th bit is 8 or more) |
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
|431 | total input bits|

#### Output

In most card games, the output of the neural network is the ID of the card to play but, in Magic Trick, the player doesn't know which cards are in their hand. Players only know the suits and relative locations of their cards (also encoded in the observation data above). Because of this, the output will be the index of card to play from their hand.

| bits | description |
| ---- | ----------- |
| 14 bits | index of card to play (during playCard state) |
| 14 bits | index of card to bid (during optionalBid state) |
| 1 bit | pass (during optionalBid state) |
| | |
| 29 bits | total output bits |