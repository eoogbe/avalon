Random = require "./random"

NUM_PLAYERS_NEEDED = [
  [2, 3, 2, 3, 3],
  [2, 3, 3, 3, 4],
  [2, 3, 3, 4, 4]
]

MIN_PLAYERS = 5
MAX_QUESTS = 5
FAIL_WEIRDNESS_QUEST_NO = 4
MIN_FAIL_WEIRDNESS_PLAYERS = 7

getValueAt = (num, arr) ->
  idx = Math.min Math.max(0, num), arr.length - 1
  arr[idx]

class CharacterSelection
  CHARACTERS_PER_PLAYERS = [
    ["Good", "Good", "Good", "Bad", "Bad"],
    ["Good", "Good", "Good", "Good", "Bad", "Bad"],
    ["Good", "Good", "Good", "Good", "Bad", "Bad", "Bad"]
  ]
  
  constructor: (numPlayers) ->
    @characters = getValueAt(numPlayers, CHARACTERS_PER_PLAYERS).slice 0
  
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
    perQuest = getValueAt numPlayers - MIN_PLAYERS, NUM_PLAYERS_NEEDED
    getValueAt numQuests, perQuest
  getNumFailsRequired: (numPlayers, numQuests) ->
    hasFailWeirdness = numQuests + 1 is FAIL_WEIRDNESS_QUEST_NO and  # add current quest
      numPlayers >= MIN_FAIL_WEIRDNESS_PLAYERS
    unless hasFailWeirdness then 1 else 2
