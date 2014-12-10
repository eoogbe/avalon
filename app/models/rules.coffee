Random = require "./random"

NUM_PLAYERS_NEEDED = [
  [2, 3, 2, 3, 3],
  [2, 3, 3, 3, 4]
]

MIN_PLAYERS = 5
MAX_QUESTS = 5

getPosNumLessThan = (max, num) ->
  Math.min Math.max(0, num), max - 1

class CharacterSelection
  CHARACTERS_PER_PLAYERS = [
    ["Good", "Good", "Good", "Bad", "Bad"],
    ["Good", "Good", "Good", "Good", "Bad", "Bad"]
  ]
  
  constructor: (numPlayers) ->
    perPlayerIdx = getPosNumLessThan CHARACTERS_PER_PLAYERS.length, numPlayers
    @characters = CHARACTERS_PER_PLAYERS[perPlayerIdx].slice 0
  
  assignCharacter: ->
    if @characters.length > 0
      character = Random.nextChoice @characters
      removeIdx = @characters.indexOf character
      @characters.splice removeIdx, 1
      character
    else
      Random.nextChoice ["Good", "Bad"]

module.exports =
  MIN_PLAYERS: MIN_PLAYERS
  CharacterSelection: CharacterSelection
  getNumPlayersNeeded: (numPlayers, numQuests) ->
    perQuest =
      getPosNumLessThan NUM_PLAYERS_NEEDED.length, numPlayers - MIN_PLAYERS
    questNo = getPosNumLessThan MAX_QUESTS, numQuests
    
    NUM_PLAYERS_NEEDED[perQuest][questNo]
