@Avalon ?= {}
Avalon.Main = (socket) ->
  WAITING_SIGNAL_DELAY = 5000
  WAITING_SIGNALS = [
    "twiddling thumbs", "counting ceiling tiles", "fiddling with clothes",
    "falling asleep", "checking email", "checking texts", "browsing Facebook",
    "browsing Yik Yak", "taking a smoke break", "having a quickie"
  ]
  
  self = this
  
  user = null
  player = null
  character = null
  game = null
  quest = null
  questVote = null
  questOutcome = null
  nav = null
  
  self.user = -> user = user or new Avalon.User socket, self
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
  self._waitingDialogMsg = ko.observable()
  
  self.hasAlert = ko.pureComputed((->
    self.alert()? and not $.isEmptyObject self.alert()
  ), self)
  
  changeWaitingSignal = ->
    $("#waiting-signal").text "#{_.sample WAITING_SIGNALS}..."
  
  self.waitingDialogMsg = ko.pureComputed
    read: self._waitingDialogMsg
    write: (value) ->
      self._waitingDialogMsg value
      
      changeWaitingSignal()
      setInterval changeWaitingSignal, WAITING_SIGNAL_DELAY
    owner: self
  
  self.alertVote = ->
    unless $("#action-dialog").hasClass "in"
      self.alert
        message: "The king has made their final decision. Vote to approve or reject the proposed quest."
        type: "alert-warning"
  
  as2Digits = (num) ->
    if num.toString().length >= 2 then num else "0#{num}"
  
  self.formatDate = (dateStr) ->
    date = new Date dateStr
    ymd = "#{date.getFullYear()}-#{as2Digits date.getMonth()}-#{as2Digits date.getDate()}"
    hms = " #{as2Digits date.getHours()}:#{as2Digits date.getMinutes()}:#{as2Digits date.getSeconds()}"
    ymd + hms
  
  self
