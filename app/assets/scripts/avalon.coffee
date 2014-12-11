@Avalon ?= {}
Avalon.Main = (socket) ->
  WAITING_SIGNAL_DELAY = 5000
  WAITING_SIGNALS = [
    "twiddling thumbs", "counting ceiling tiles", "fiddling with clothes",
    "falling asleep", "checking email", "checking texts", "browsing Facebook",
    "browsing Yik Yak", "taking a smoke break", "having a quickie"
  ]
  
  self = this
  
  player = null
  character = null
  game = null
  quest = null
  questVote = null
  questOutcome = null
  nav = null
  
  self.player = -> player = player or new Avalon.Player socket, self
  self.character = ->
    character = character or new Avalon.Character socket, self
  self.game = -> game = game or new Avalon.Game socket, self
  self.quest = -> quest = quest or new Avalon.Quest socket, self
  self.questVote = ->
    questVote = questVote or new Avalon.QuestVote socket, self
  self.questOutcome = ->
    questOutcome = questOutcome or new Avalon.QuestOutcome socket, self
  self.nav = -> nav = nav or new Avalon.Navigation socket, self
  
  self.alert = ko.observable()
  self.confirmDialog = ko.observable({})
  self.actionDialog = ko.observable({})
  self.infoDialog = ko.observable({})
  self._waitingDialog = ko.observable({})
  
  self.hasAlert = ko.pureComputed((->
    self.alert()? and not $.isEmptyObject self.alert()
  ), self)
  
  self.waitingSignalId = null
  
  changeWaitingSignal = ->
    $("#waiting-signal").text "#{_.sample WAITING_SIGNALS}..."
  
  self.waitingDialog = ko.pureComputed
    read: self._waitingDialog
    write: (value) ->
      self._waitingDialog value
      
      unless value.isDone
        changeWaitingSignal()
        self.waitingSignalId =
          setInterval changeWaitingSignal, WAITING_SIGNAL_DELAY
      else
        clearInterval self.waitingSignalId
        $("#waiting-signal").text ""
    owner: self
  
  self.alertVote = ->
    unless $("#action-dialog").hasClass "in"
      self.alert
        message: "The king has made their final decision. Vote to approve or reject the proposed quest."
        type: "alert-warning"
  
  self.formatDate = (dateStr) ->
    date = new Date dateStr
    "#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()} #{date.getHours()}:#{date.getMinutes()}:#{date.getSeconds()}"
  
  self
