module.exports = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  Site = eventCtx.models.Site
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  
  (data) ->
    Site.current data, (err, siteData) ->
      return console.error err if err
      
      player = siteData.currentPlayer
      game = siteData.currentGame
      quest = siteData.currentQuest
      questStats = siteData.questStats
      
      if not quest
        Quest.upsert data.gameId, (err, quest) ->
          return console.error err if err
          
          populatedFields = [{ path: "king" }, { path: "players" }]
          Quest.populate quest, populatedFields, (err, quest) ->
            return console.error err if err
            
            QuestVote.find quest: quest
              .populate "player"
              .exec (err, votes) ->
                return console.error err if err
                
                socket.join game.name
                
                isKing = quest.king.name is session.user
                page = if isKing then "new_questors" else "questors"
                socket.emit "show_#{page}",
                  currentQuest: quest
                  currentGame: game
                  votes: votes
                  knownPlayers: game.playersKnownTo player
                  questStats: questStats
      else if quest.players.some((p) -> p._id.equals data.playerId)
        socket.join game.name
        
        socket.emit "show_new_quest_outcome",
          currentGame: game
          currentQuest: quest
          knownPlayers: game.playersKnownTo player
          questStats: questStats
      else
        QuestVote.find({ quest: quest }).populate("player").exec (err, votes) ->
          return console.error err if err
          
          socket.join game.name
          
          socket.emit "show_quest_votes",
            currentGame: game
            currentQuest: quest
            isLastRejectableQuest: game.isOnLastRejectableQuest()
            knownPlayers: game.playersKnownTo player
            questStats: questStats
            votes: votes
