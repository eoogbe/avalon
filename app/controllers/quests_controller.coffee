handleStateChange = (eventCtx, quest, noChangeFn) ->
  io = eventCtx.io
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  
  Quest.populate quest, { path: "game" }, (err, quest) ->
    throw err if err
    
    switch quest.state
      when "unstarted", "voting"
        noChangeFn quest
      when "rejected", "playing"
        Player.findQuestPlayers quest, (err, king, questPlayers) ->
          throw err if err
          
          QuestVote.find { quest: quest }, (err, votes) ->
            throw err if err
            
            Player.findVoters votes, (err, approvers, rejectors) ->
              throw err if err
              
              game = quest.game
              
              Player.findGamePlayers game, (err, gamePlayers) ->
                throw err if err
                
                io.to(game.name).emit "show_quest_votes",
                  currentGame: game
                  gamePlayers: gamePlayers
                  currentQuest: quest
                  questPlayers: questPlayers
                  isLastRejectableQuest: game.isOnLastRejectableQuest()
                  votes: votes
                  approvers: approvers
                  rejectors: rejectors
                
                if game.state is "bad_won"
                  io.to(game.name).emit "show_gameover",
                    currentGame: game
                    gamePlayers: gamePlayers

exports.updated = (eventCtx) ->
  socket = eventCtx.socket
  session = socket.request.session
  Player = eventCtx.models.Player
  Game = eventCtx.models.Game
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  
  (gameId) ->
    Quest.upsert gameId, (err, quest) ->
      throw err if err
      
      Game.findById gameId, (err, game) ->
        throw err if err
        
        Player.findGamePlayers game, (err, gamePlayers) ->
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
                  currentGame: game
                  gamePlayers: gamePlayers
                  currentQuest: quest
                  king: king
                  questPlayers: questPlayers
                  votes: votes
                  approvers: approvers
                  rejectors: rejectors

exports.votedOn = (eventCtx) ->
  io = eventCtx.io
  socket = eventCtx.socket
  Player = eventCtx.models.Player
  Quest = eventCtx.models.Quest
  QuestVote = eventCtx.models.QuestVote
  
  (data) ->
    Quest.findByIdAndCreateVote data.questId, data.playerId, data.vote,
      (err, quest, nonvoters) ->
        throw err if err
        
        handleStateChange eventCtx, quest, (quest) ->
          if quest.state is "unstarted"
            Player.findById quest.king, (err, king) ->
              throw err if err
              
              QuestVote.find { quest: quest }, (err, votes) ->
                throw err if err
                
                Player.findVoters votes, (err, approvers, rejectors) ->
                  throw err if err
                  
                  for id, conn of io.of("/").connected when king.user.equals conn.request.session.user
                    conn.emit "set_votes",
                      votes: votes
                      approvers: approvers
                      rejectors: rejectors
          else
            socket.emit "wait_on_voters"

exports.started = (eventCtx) ->
  io = eventCtx.io
  Quest = eventCtx.models.Quest
  
  (questId) ->
    Quest.findByIdAndUpdate questId, state: "voting"
      .populate "votes"
      .exec (err, quest) ->
        throw err if err
        
        quest.checkApproved (err, quest, nonvoters) ->
          throw err if err
          
          handleStateChange eventCtx, quest, (quest) ->
            for id, conn of io.of("/").connected when quest.game.name in conn.rooms
              currentUser = conn.request.session.user
              if nonvoters.some((player) -> player.user.equals currentUser)
                conn.emit "alert_vote"
              else
                conn.emit "wait_on_voters"
