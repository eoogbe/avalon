Avalon = ->
    self = this
    
    self.currentPage = ko.observable "new_quest"
    self.questState = ko.observable()
    self.winnerType = ko.observable()
    self.quests = ko.observableArray()
    
    filteredQuests = (state) ->
        ko.utils.arrayFilter self.quests(), (quest) ->
            quest is state
    
    self.numSucceeded = ko.computed((->
        filteredQuests("succeeded").length
    ), self)
    
    self.numFailed = ko.computed((->
        filteredQuests("failed").length
    ), self)
    
    self.isCurrentPage = (pageName) ->
        self.currentPage() is pageName
    
    gameover = (winnerType) ->
        self.winnerType winnerType
        self.quests.removeAll()
        self.currentPage "gameover"
    
    createOutcome = (outcome) ->
        self.questState outcome
        self.quests.push outcome
        
        if self.numSucceeded() >= 3
            gameover "Good"
        else if self.numFailed() >= 3
            gameover "Bad"
        else
            self.currentPage "quest"
    
    self.createSuccessOutcome = ->
        createOutcome "succeeded"
    
    self.createFailOutcome = ->
        createOutcome "failed"
    
    self.nextQuest = ->
        self.currentPage "new_quest"
    
    self.playAgain = ->
        self.currentPage "new_quest"
    
    self

$ -> ko.applyBindings new Avalon()
