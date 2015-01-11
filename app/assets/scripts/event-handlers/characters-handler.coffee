@Avalon ?= {}
Avalon.EventHandlers ?= {}
Avalon.EventHandlers.Characters = (socket, viewModel) ->
  uncheckCharacters = (type, max) ->
    characterSelector = ".character-#{type}:checked"
    specialCharactersSelector = "#character-merlin, #character-assassin"
    while $(characterSelector).length > max
      $character = $(characterSelector).not(specialCharactersSelector).last()
      $character.prop "checked", false
  
  uncheckAllCharacterOverflow = ->
    uncheckCharacters "good", viewModel.character().numGood()
    uncheckCharacters "bad", viewModel.character().numBad()
  
  enableCreateCharacterBtn = ->
    numCharacters = $(".character-type:checked").length
    numPlayers = viewModel.character().count()
    $("#create-characters-btn").prop "disabled", numCharacters isnt numPlayers
  
  registerDependentCharacterListener = (instigator, dependent) ->
    $("#character-#{instigator}").change ->
      $("#character-#{dependent}").prop "checked", $(this).is(":checked")
      uncheckAllCharacterOverflow()
  
  socket.on "show_new_characters", (data) ->
    viewModel.player().current data.currentPlayer
    viewModel.game().current data.currentGame
    viewModel.game().players data.gamePlayers
    viewModel.character().stats data.characterStats
    viewModel.nav().currentPage "new_characters"
    
    $(".character-normal").change uncheckAllCharacterOverflow
    registerDependentCharacterListener "assassin", "merlin"
    registerDependentCharacterListener "merlin", "assassin"
    $(".character-type").change enableCreateCharacterBtn
