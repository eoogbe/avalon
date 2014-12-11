module.exports = (models) ->
  current: (data, done) ->
    models.Player.findById data.playerId, (err, player) ->
      return done err if err
      
      models.Game.findById(data.gameId).populate("players").exec (err, game) ->
        return done err if err
        
        models.Quest.statsFor game, (err, questStats) ->
          return done err if err
          
          models.Quest.findOne { game: data.gameId, state: "playing" }
            .populate "players king"
            .exec (err, quest) ->
              done err,
                currentPlayer: player
                currentGame: game
                currentQuest: quest
                questStats: questStats
                characterStats: models.Rules.getCharacterStats game.players.length
