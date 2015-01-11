@Avalon ?= {}
Avalon.Character = (socket, root) ->
  NUM_GOOD_IMGS = 5
  NUM_BAD_IMGS = 3
  
  self = this
  
  self.stats = ko.observable({})
  
  self.current = ko.pureComputed((->
    if root.player().hasCurrent() then self.for_ root.player().current().character else ""
  ), self)
  
  self.numGood = ko.pureComputed((->
    self.stats().numGood
  ), self)
  
  self.numBad = ko.pureComputed((->
    self.stats().numBad
  ), self)
  
  self.goodList = ko.pureComputed((->
    _.filter root.game().players(), self.isGood
  ), self)
  
  self.count = ko.pureComputed((->
    self.numGood() + self.numBad()
  ), self)
  
  self.isAssassin = ko.pureComputed((->
    root.player().current().character is "assassin"
  ), self)
  
  self.img = ->
    currentCharacter = root.player().current().character
    return unless currentCharacter?
    
    if currentCharacter is "good"
      num = _.random 1, NUM_GOOD_IMGS
      "/images/good#{num}_small.jpg"
    else if currentCharacter is "bad"
      num = _.random 1, NUM_BAD_IMGS
      "/images/bad#{num}_small.jpg"
    else
      "/images/#{currentCharacter}_small.jpg"
  
  self.for_ = (character) ->
    return unless character?
    
    if character is "good"
      "a Loyal Servant of Arthur"
    else if character is "bad"
      "a Minion of Mordred"
    else if character is "assassin"
      "the Assassin"
    else
      character.charAt(0).toUpperCase() + character.slice(1).toLowerCase()
  
  self.isGood = (player) ->
    player.character in ["good", "merlin"]
  
  self.create = ->
    socket.emit "characters_created",
      gameId: root.game().currentId()
      characters: _.map $(".character-type:checked"), "value"
  
  self
