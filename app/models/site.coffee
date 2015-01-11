module.exports = (models) ->
  current: (data, done) ->
    models.Player.findById data.playerId, (err, player) ->
      return done err if err
      
      models.Game.findById data.gameId, (err, game) ->
        return done err if err
        
        models.Player.findGamePlayers game, (err, gamePlayers) ->
          return done err if err
          
          models.Quest.statsFor game, (err, questStats) ->
            return done err if err
            
            questConditions = { game: data.gameId, state: "playing" }
            models.Quest.findOne questConditions, (err, quest) ->
              data =
                currentPlayer: player
                currentGame: game
                currentQuest: quest
                gamePlayers: gamePlayers
                questStats: questStats
                characterStats: models.Rules.getCharacterStats game.players.length
                knownPlayers: models.Rules.getPlayersKnown player, gamePlayers
              
              return done err, data if err or not quest
              
              models.Player.findQuestPlayers quest, (err, king, questPlayers) ->
                data.king = king
                data.questPlayers = questPlayers
                done err, data
