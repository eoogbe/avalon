Random = require "./random"

NUM_GOOD = [3, 4, 4, 5, 6, 6]
NUM_BAD = [2, 2, 3, 3, 3, 4]

NUM_PLAYERS_NEEDED = [
  [2, 3, 2, 3, 3],
  [2, 3, 3, 3, 4],
  [2, 3, 3, 4, 4],
  [3, 4, 4, 5, 5],
  [3, 4, 4, 5, 5],
  [3, 4, 4, 5, 5]
]

MIN_PLAYERS = 5
MAX_QUESTS = 5
FAIL_WEIRDNESS_QUEST_NO = 4
MIN_FAIL_WEIRDNESS_PLAYERS = 7

getPlayerIdx = (numPlayers) -> numPlayers - MIN_PLAYERS

getValueAt = (num, arr) ->
  idx = Math.min Math.max(0, num), arr.length - 1
  arr[idx]

class CharacterSelection
  constructor: (@characters) ->
  
  assignCharacter: ->
    if @characters.length > 0
      character = Random.nextChoice @characters
      removeIdx = @characters.indexOf character
      @characters.splice removeIdx, 1
      character
    else
      Random.nextChoice ["good", "bad"]

module.exports =
  MIN_PLAYERS: MIN_PLAYERS
  CharacterSelection: CharacterSelection
  getCharacterStats: (numPlayers) ->
    return null unless numPlayers?
    
    playerIdx = getPlayerIdx numPlayers
    numGood: getValueAt playerIdx, NUM_GOOD
    numBad: getValueAt playerIdx, NUM_BAD
  getPlayersKnown: (player, players) ->
    if player.character is "good"
      []
    else if player.character in ["bad", "assassin", "mordred"]
      players.filter (p) ->
        p.character in ["bad", "assassin", "mordred"] and not p.equals player
    else if player.character is "merlin"
      players.filter (p) -> p.character in ["bad", "assassin"]
  getNumPlayersNeeded: (numPlayers, numQuests) ->
    perQuest = getValueAt getPlayerIdx(numPlayers), NUM_PLAYERS_NEEDED
    getValueAt numQuests, perQuest
  getNumFailsRequired: (numPlayers, numQuests) ->
    hasFailWeirdness = numQuests + 1 is FAIL_WEIRDNESS_QUEST_NO and  # add current quest
      numPlayers >= MIN_FAIL_WEIRDNESS_PLAYERS
    unless hasFailWeirdness then 1 else 2
