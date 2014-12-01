exports.created = (io, models) ->
  (data) ->
    models.Game.findById data.gameId, (err, game) ->
      return console.error err if err
      
      models.Quest.create { state: data.state, game: game }, (err, quest) ->
        return console.error err if err
        
        game.checkGameover (data) ->
          if data.isGameover
            io.emit "show_gameover", data.game
          else
            io.emit "show_quest",
              quest: quest
              questStats: data.questStats
