module.exports = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  Site = eventCtx.models.Site
  Player = eventCtx.models.Player
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  Rules = eventCtx.models.Rules
  
  (data) ->
    Site.current data, (err, siteData) ->
      throw err if err
      
      player = siteData.currentPlayer
      game = siteData.currentGame
      quest = siteData.currentQuest
      king = siteData.king
      gamePlayers = siteData.gamePlayers
      questPlayers = siteData.questPlayers
      knownPlayers = siteData.knownPlayers
      questStats = siteData.questStats
      characterStats = siteData.characterStats
      
      socket.join game.name
      
      if game.state is "setup"
        socket.emit "show_new_characters",
          currentPlayer: players
          currentGame: game
          gamePlayers: gamePlayers
          characterStats: characterStats
      else if game.state is "assassinating"
        socket.emit "show_merlin_selection",
          currentPlayer: player
          currentGame: game
          gamePlayers: gamePlayers
          knownPlayers: knownPlayers
          questStats: questStats
          characterStats: characterStats
      else if not quest
        Quest.upsert data.gameId, (err, quest) ->
          throw err if err
          
          Player.findQuestPlayers quest, (err, king, questPlayers) ->
            throw err if err
            
            QuestVote.find { quest: quest }, (err, votes) ->
              throw err if err
              
              Player.findVoters votes, (err, approvers, rejectors) ->
                throw err if err
                
                isKing = king.user._id.equals session.user
                page = if isKing then "new_questors" else "questors"
                socket.emit "show_#{page}",
                  currentPlayer: player
                  currentGame: game
                  currentQuest: quest
                  king: king
                  gamePlayers: gamePlayers
                  questPlayers: questPlayers
                  knownPlayers: knownPlayers
                  votes: votes
                  approvers: approvers
                  rejectors: rejectors
                  questStats: questStats
                  characterStats: characterStats
      else if quest.players.some((p) -> p.equals data.playerId)
        socket.emit "show_new_quest_outcome",
          currentPlayer: player
          currentGame: game
          currentQuest: quest
          king: king
          gamePlayers: gamePlayers
          questPlayers: questPlayers
          knownPlayers: knownPlayers
          questStats: questStats
          characterStats: characterStats
      else
        QuestVote.find { quest: quest }, (err, votes) ->
          throw err if err
          
          Player.findVoters votes, (err, approvers, rejectors) ->
            throw err if err
            
            socket.emit "show_quest_votes",
              currentPlayer: player
              currentGame: game
              currentQuest: quest
              king: king
              gamePlayers: gamePlayers
              questPlayers: questPlayers
              knownPlayers: knownPlayers
              isLastRejectableQuest: game.isOnLastRejectableQuest()
              questStats: questStats
              characterStats: characterStats
              votes: votes
              approvers: approvers
              rejectors: rejectors
