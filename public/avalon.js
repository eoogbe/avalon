(function() {
  var Avalon;

  Avalon = function() {
    var createOutcome, filteredQuests, gameover, self;
    self = this;
    self.currentPage = ko.observable("new_quest");
    self.questState = ko.observable();
    self.winnerType = ko.observable();
    self.quests = ko.observableArray();
    filteredQuests = function(state) {
      return ko.utils.arrayFilter(self.quests(), function(quest) {
        return quest === state;
      });
    };
    self.numSucceeded = ko.computed((function() {
      return filteredQuests("succeeded").length;
    }), self);
    self.numFailed = ko.computed((function() {
      return filteredQuests("failed").length;
    }), self);
    self.isCurrentPage = function(pageName) {
      return self.currentPage() === pageName;
    };
    gameover = function(winnerType) {
      self.winnerType(winnerType);
      self.quests.removeAll();
      return self.currentPage("gameover");
    };
    createOutcome = function(outcome) {
      self.questState(outcome);
      self.quests.push(outcome);
      if (self.numSucceeded() >= 3) {
        return gameover("Good");
      } else if (self.numFailed() >= 3) {
        return gameover("Bad");
      } else {
        return self.currentPage("quest");
      }
    };
    self.createSuccessOutcome = function() {
      return createOutcome("succeeded");
    };
    self.createFailOutcome = function() {
      return createOutcome("failed");
    };
    self.nextQuest = function() {
      return self.currentPage("new_quest");
    };
    self.playAgain = function() {
      return self.currentPage("new_quest");
    };
    return self;
  };

  $(function() {
    return ko.applyBindings(new Avalon());
  });

}).call(this);
